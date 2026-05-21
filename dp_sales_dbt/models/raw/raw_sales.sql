{{
    config (
      unique_key = "sales_hash_diff"
    )
}}
with
  cte_raw_sales as (
    select
      *,
      get_current_timestamp() as load_ts
    from
      {{ source ('external_source', 'sales') }}
  )
select
  md5(
    concat_ws(
      '|',
      coalesce(order_id, 'default_value'),
      coalesce(product_id, 'default_value'),
      coalesce(customer_id, 'default_value'),
      coalesce(order_date, 'default_value'),
      coalesce(order_amount, 'default_value'),
      coalesce(order_quantity, 'default_value'),
      coalesce(payment_method, 'default_value'),
      coalesce(discount_applied, 'default_value'),
      coalesce(shipping_cost, 'default_value'),
      coalesce(created_at, 'default_value')
    )
  ) as sales_hash_diff,
  *
from cte_raw_sales

{% if is_incremental () %}
where
  filename not in (
    select
      filename
    from
      {{this}}
  ) 
{% endif %}