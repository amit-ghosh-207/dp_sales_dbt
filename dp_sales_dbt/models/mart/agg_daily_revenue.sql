{{
    config (
      materialized = "view"
    )
}}

SELECT
    dd.date_key as order_date,
    COALESCE(sum(order_amount), 0) as total_order_amount,
    COALESCE(count(DISTINCT order_id), 0) as order_count,
    COALESCE(count(DISTINCT customer_id), 0) as unique_customer_count
FROM {{ ref('fact_sales') }} as fs
right join {{ ref('dim_date') }} as dd on fs.order_date = dd.date_key

where {{ get_date_interval('dd.date_key', '2024-01-01', 1)  }}

group by dd.date_key