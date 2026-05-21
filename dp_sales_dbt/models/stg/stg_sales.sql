{{
    config (
      unique_key = ["sales_hash_diff", "source_file_name"]
    )
}}
with
  cte_raw_sales as (
    select
      sales_hash_diff,
      order_id,
      product_id,
      customer_id,
      cast(order_date as date) as order_date,
      order_amount::decimal(15, 2) as order_amount,
      order_quantity::integer as order_quantity,
      payment_method,
      discount_applied::decimal(15, 2) as discount_applied,
      shipping_cost::decimal(15, 2) as shipping_cost,
      strptime(created_at, '%Y-%m-%d %H:%M:%S') as created_at,
      filename,
      load_ts as raw_load_ts
    from
      {{ ref('raw_sales') }}
  )
select
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
  get_current_timestamp() as load_ts
from cte_raw_sales

{% if is_incremental () %}
where
  raw_load_ts > (
    select
      max(load_ts)
    from
      {{this}}
  )
{% endif %}
