{{
    config (
      unique_key = "sales_hash_diff"
    )
}}
WITH
  cte_raw_sales AS (
    SELECT
      *,
      get_current_timestamp() AS load_ts
    FROM
      {{ source ('external_source', 'sales') }}
  )
SELECT
  MD5(
    concat_ws(
      '|',
      COALESCE(order_id, 'default_value'),
      COALESCE(product_id, 'default_value'),
      COALESCE(customer_id, 'default_value'),
      COALESCE(order_date, 'default_value'),
      COALESCE(order_amount, 'default_value'),
      COALESCE(order_quantity, 'default_value'),
      COALESCE(payment_method, 'default_value'),
      COALESCE(discount_applied, 'default_value'),
      COALESCE(shipping_cost, 'default_value'),
      COALESCE(created_at, 'default_value')
    )
  ) AS sales_hash_diff,
  *
FROM cte_raw_sales

{% if is_incremental () %}
WHERE
  filename NOT IN (
    SELECT
      filename
    FROM
      {{this}}
  ) 
{% endif %}