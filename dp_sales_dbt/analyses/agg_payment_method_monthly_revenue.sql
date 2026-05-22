with
    cte_agg_order as (
        select
            fs.payment_method,
            sum(coalesce(fs.order_amount, 0)) as total_order_amount,
            count(distinct fs.order_id) as  order_count,
            round(avg(coalesce(fs.order_amount, 0)), 2) as avg_order_amount
        from
            {{ref ('fact_sales')}} as fs
        group by
            fs.payment_method
    )
select
    payment_method,
    order_count,
    avg_order_amount,
    total_order_amount,
    round(
        (
            if(
                sum(total_order_amount) over () = 0,
                0,
                total_order_amount * 100.0 / sum(total_order_amount) over ()
            )
        ),
    2) as percentage_share,
    get_current_timestamp() as load_ts
from
    cte_agg_order
order by
    month_key,
    product_category_id,
    payment_method