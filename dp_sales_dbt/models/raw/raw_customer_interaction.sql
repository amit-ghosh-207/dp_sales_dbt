{{
    config (
      unique_key = ["customer_interaction_hash_diff", "filename"]
    )
}}
with
  cte_raw_customer_interaction as (
    select
      *,
      get_current_timestamp() as load_ts
    from
      {{ source ('external_source', 'customer_interaction') }}
  )
select
  md5(
    concat_ws(
      '|',
      coalesce(customer_id, 'default_value'),
      coalesce(product_id, 'default_value'),
      coalesce(interaction_type, 'default_value'),
      coalesce("timestamp", 'default_value'),
      filename,
      load_ts
    )
  ) as customer_interaction_hash_diff,
  *
from cte_raw_customer_interaction

{% if is_incremental () %}
where
  filename not in (
    select
      filename
    from
      {{this}}
  )
{% endif %}
