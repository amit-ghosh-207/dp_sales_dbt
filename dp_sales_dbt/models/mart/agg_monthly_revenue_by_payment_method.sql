{{
    config (
      unique_key = [
        "month_key",
        "product_category_id",
        "payment_method",
    ]
    )
}}

with
    cte_agg_order as (
        select
            dd.month_key,
            dp.product_category_id,
            fs.payment_method,
            sum(coalesce(fs.order_amount, 0)) as total_monthly_order_amount,
            sum(coalesce(fs.order_quantity, 0)) as total_monthly_order_quantity,
            count(distinct fs.order_id) as  order_count,
            round(avg(coalesce(fs.order_amount, 0)), 2) as avg_order_amount,
            get_current_timestamp() as load_ts
        from
            {{ref ('fact_sales')}} as fs
            inner join {{ ref('dim_product') }} as dp on fs.product_id = dp.product_id
            inner join {{ ref('dim_date') }} as dd on fs.order_date = dd.date_key
        {% if is_incremental () %}
            where 1 = 1
                and fs.order_date = '{{ dbt_airflow_macros.ds(timezone=none) }}'::date
        {% endif %}
        group by
            dd.month_key,
            dp.product_category_id,
            fs.payment_method
    )
select
    month_key,
    product_category_id,
    payment_method,
    order_count,
    avg_order_amount,
    total_monthly_order_amount,
    total_monthly_order_quantity,
    round(
        (
            if(
                sum(total_monthly_order_amount) over () = 0,
                0,
                total_monthly_order_amount * 100.0 / sum(total_monthly_order_amount) over ()
            )
        ),
    2) as percentage_share
from
    cte_agg_order
order by
    month_key,
    product_category_id,
    payment_method