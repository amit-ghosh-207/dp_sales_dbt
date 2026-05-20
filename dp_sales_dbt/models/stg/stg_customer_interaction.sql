{{
    config (
      unique_key = ["customer_interaction_hash_diff", "source_file_name"],
      tags = ["core", "events"]
    )
}}
WITH
  cte_raw_customer_interaction AS (
    SELECT
      customer_interaction_hash_diff,
      customer_id,
      product_id,
      interaction_type,
      strptime("timestamp", '%Y-%m-%d %H:%M:%S') as interaction_ts,
      filename,
      load_ts as raw_load_ts
    FROM
      {{ ref('raw_customer_interaction') }}
  )
SELECT
  customer_interaction_hash_diff,
  customer_id,
  product_id,
  interaction_type,
  interaction_ts,
  filename as source_file_name,
  get_current_timestamp() AS load_ts
FROM cte_raw_customer_interaction

{% if is_incremental () %}
WHERE
  raw_load_ts > (
    SELECT
      max(load_ts)
    FROM
      {{this}}
  ) 
{% endif %}