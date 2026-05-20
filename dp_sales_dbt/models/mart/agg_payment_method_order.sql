{{
    config (
      materialized = "table", 
      tags = ["core", "events"]
    )
}}

WITH
    cte_agg_order AS (
        SELECT
            fs.order_id,
            fs.payment_method,
            sum(fs.order_amount) AS total_order_amount
        FROM
            {{ref ('fact_sales')}} AS fs
        GROUP BY
            fs.order_id,
            fs.payment_method
    )
SELECT
    payment_method,
    count(order_id) as order_count,
    round(avg(total_order_amount), 2) AS avg_order_amount,
    sum(total_order_amount) AS total_payment_method_order_amount,
    ROUND(
        (
            total_payment_method_order_amount * 100.0 / SUM(total_payment_method_order_amount) OVER ()
        ),
    2) AS percentage_share
FROM
    cte_agg_order
GROUP BY
    payment_method