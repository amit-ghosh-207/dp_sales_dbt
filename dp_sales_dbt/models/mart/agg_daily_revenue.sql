{{
    config (
      materialized = "view"
    )
}}

select
    dd.date_key as order_date,
    coalesce(sum(order_amount), 0) as total_order_amount,
    coalesce(count(distinct order_id), 0) as order_count,
    coalesce(count(distinct customer_id), 0) as unique_customer_count
from {{ ref('fact_sales') }} as fs
right join {{ ref('dim_date') }} as dd on fs.order_date = dd.date_key

where {{ get_date_interval('dd.date_key', '2024-01-01', 1)  }}

group by dd.date_key