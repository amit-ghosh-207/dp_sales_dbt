{{
    config (
      materialized = "table"
      tags = ["core", "events"]
    )
}}

SELECT
    order_date,
    sum(order_amount) as order_amount
FROM {{ ref('fact_sales') }}
where {{ get_date_interval('order_date', '2024-01-01', 60)  }}
group by order_date