{{
    config (
      unique_key = ["sales_hash_diff", "source_file_name"]
    )
}}
WITH
  cte_raw_sales AS (
    SELECT
      sales_hash_diff,
      order_id,
      product_id,
      customer_id,
      CAST(order_date AS DATE) as order_date,
      order_amount::DECIMAL(15, 2) as order_amount,
      order_quantity::INTEGER as order_quantity,
      payment_method,
      discount_applied::DECIMAL(15, 2) as discount_applied,
      shipping_cost::DECIMAL(15, 2) as shipping_cost,
      strptime(created_at, '%Y-%m-%d %H:%M:%S') as created_at,
      filename,
      load_ts as raw_load_ts
    FROM
      {{ ref('raw_sales') }}
  )
SELECT
  sales_hash_diff,
  order_id,
  product_id,
  customer_id,
  order_date,
  order_amount,
  order_quantity,
  payment_method,
  discount_applied,
  shipping_cost,
  created_at,
  filename as source_file_name,
  get_current_timestamp() AS load_ts
FROM cte_raw_sales

{% if is_incremental () %}
WHERE
  raw_load_ts > (
    SELECT
      max(load_ts)
    FROM
      {{this}}
  ) 
{% endif %}