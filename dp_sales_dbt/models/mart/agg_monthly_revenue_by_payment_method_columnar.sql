{{
    config (
      unique_key = [
        "month_key",
        "product_category_id"
    ]
    )
}}

with
    cte_agg_order as (
        select
            dd.month_key,
            dp.product_category_id,
            sum(coalesce(fs.order_amount, 0)) as total_monthly_order_amount,
            sum(coalesce(fs.order_quantity, 0)) as total_monthly_order_quantity,
            count(distinct fs.order_id) as  order_count,
            round(avg(coalesce(fs.order_amount, 0)), 2) as avg_order_amount,
            sum(coalesce(if(fs.payment_method = 'credit_card', fs.order_amount, 0), 0)) as total_credit_card_order_amount,
            sum(coalesce(if(fs.payment_method = 'debit_card',fs.order_amount, 0), 0)) as total_debit_card_order_amount,
            sum(coalesce(if(fs.payment_method = 'paypal', fs.order_amount, 0), 0)) as total_paypal_order_amount,
            sum(coalesce(if(fs.payment_method = 'bank_transfer', fs.order_amount, 0), 0)) as total_bank_transfer_order_amount,
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
            dp.product_category_id
    )
select
    month_key,
    product_category_id,
    order_count,
    avg_order_amount,
    total_monthly_order_amount,
    total_monthly_order_quantity,
    total_credit_card_order_amount,
    total_debit_card_order_amount,
    total_paypal_order_amount,
    total_bank_transfer_order_amount,
    round(total_credit_card_order_amount * 100.0 / nullif(total_monthly_order_amount, 0), 2) as credit_card_percentage_share,
    round(total_debit_card_order_amount * 100.0 / nullif(total_monthly_order_amount, 0), 2) as debit_card_percentage_share,
    round(total_paypal_order_amount * 100.0 / nullif(total_monthly_order_amount, 0), 2) as paypal_percentage_share,
    round(total_bank_transfer_order_amount * 100.0 / nullif(total_monthly_order_amount, 0), 2) as bank_transfer_percentage_share
from
    cte_agg_order
order by
    month_key,
    product_category_id