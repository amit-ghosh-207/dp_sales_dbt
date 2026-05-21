{{
    config (
      unique_key = ["customer_interaction_hash_diff", "source_file_name"]
    )
}}
with
  cte_raw_customer_interaction as (
    select
      customer_interaction_hash_diff,
      customer_id,
      product_id,
      interaction_type,
      strptime("timestamp", '%Y-%m-%d %H:%M:%S') as interaction_ts,
      filename,
      load_ts as raw_load_ts
    from
      {{ ref('raw_customer_interaction') }}
  )
select
  customer_interaction_hash_diff,
  customer_id,
  product_id,
  interaction_type,
  interaction_ts,
  filename as source_file_name,
  get_current_timestamp() as load_ts
from cte_raw_customer_interaction

{% if is_incremental () %}
where
  raw_load_ts > (
    select
      max(load_ts)
    from
      {{this}}
  ) 
{% endif %}