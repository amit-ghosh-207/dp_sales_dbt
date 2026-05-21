{{
    config (
      unique_key = ["order_id", "product_id", "customer_id", "order_date"]
    )
}}

SELECT
    order_id,
    product_id,
    customer_id,
    order_date,
    order_amount,
    order_quantity,
    payment_method,
    discount_applied,
    shipping_cost,
    get_current_timestamp() AS load_ts
FROM {{ ref('stg_sales') }}

{% if is_incremental () %}
WHERE
  order_date = '{{ dbt_airflow_macros.ds(timezone=none) }}'::DATE
{% endif %}