{{
    config (
      materialized = "view"
    )
}}

select
    order_id,
    product_id,
    customer_id,
    order_date,
    order_amount,
    order_quantity,
    payment_method,
    discount_applied,
    shipping_cost,
    round((coalesce(discount_applied, 0) * 100 / order_amount), 2) as discount_pct,
    round((coalesce(shipping_cost, 0) * 100 / order_amount), 2) as shipping_cost_pct,
    load_ts
from {{ ref('fact_sales') }}
where 1 = 1
  and order_amount > 0
  and (discount_pct > 30 or shipping_cost_pct> 10)