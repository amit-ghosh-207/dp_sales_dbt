{{
    config (
      materialized = "table"
    )
}}

with
    cte_agg_order as (
        select
            fs.order_id,
            fs.payment_method,
            sum(fs.order_amount) as total_order_amount
        from
            {{ref ('fact_sales')}} as fs
        group by
            fs.order_id,
            fs.payment_method
    )
select
    payment_method,
    count(order_id) as order_count,
    round(avg(total_order_amount), 2) as avg_order_amount,
    sum(total_order_amount) as total_payment_method_order_amount,
    round(
        (
            total_payment_method_order_amount * 100.0 / sum(total_payment_method_order_amount) over ()
        ),
    2) as percentage_share
from
    cte_agg_order
group by
    payment_method
