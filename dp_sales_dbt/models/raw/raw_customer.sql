{{
    config (
      unique_key = "customer_hash_diff"
    )
}}
with
  cte_raw_customer as (
    select
      *,
      get_current_timestamp() as load_ts
    from
      {{ source ('external_source', 'customer') }}
  )
select
  md5(
    concat_ws(
      '|',
      coalesce(customer_id, 'default_value'),
      coalesce(customer_name, 'default_value'),
      coalesce(customer_email, 'default_value'),
      coalesce(start_date, 'default_value'),
      coalesce(end_date, 'default_value'),
      coalesce(status, 'default_value')
    )
  ) as customer_hash_diff,
  *
from cte_raw_customer

{% if is_incremental () %}
where
  filename not in (
    select
      filename
    from
      {{this}}
  ) 
{% endif %}