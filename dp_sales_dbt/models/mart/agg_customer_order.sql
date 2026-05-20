{{
    config (
      materialized = "table", 
      tags = ["core", "events"]
    )
}}

SELECT
    dc.customer_id,
    dc.customer_name,
    coalesce(sum(fs.order_amount), 0) AS total_order_amount,
    coalesce(count(DISTINCT fs.order_id), 0) AS total_order_count,
    CASE
        WHEN total_order_amount < 500 THEN 'Low Value'
        WHEN total_order_amount < 1000 THEN 'Medium Value'
        ELSE 'High Value'
    END AS customer_tier
FROM
    {{ ref('fact_sales') }} AS fs
    RIGHT JOIN {{ ref('dim_customer') }} AS dc ON fs.customer_id = dc.customer_id

WHERE 1 = 1
    and '{{ dbt_airflow_macros.ds(timezone=none) }}'::DATE between dc.valid_from::DATE and dc.valid_to::DATE

GROUP BY
    dc.customer_id,
    dc.customer_name