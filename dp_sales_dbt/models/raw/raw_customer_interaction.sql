{{
    config (
      unique_key = "raw_customer_interaction_hash_key",
      tags = ["core", "events"]
    )
}}
WITH
  cte_raw_customer_interaction AS (
    SELECT
      *,
      get_current_timestamp() AS load_ts
    FROM
      {{ source ('external_source', 'customer_interaction') }}
  )
SELECT
  MD5(
    concat_ws(
      '|',
      COALESCE(customer_id, 'default_value'),
      COALESCE(product_id, 'default_value'),
      COALESCE(interaction_type, 'default_value'),
      COALESCE("timestamp", 'default_value'),
      filename,
      load_ts
    )
  ) AS raw_customer_interaction_hash_key,
  *
FROM cte_raw_customer_interaction

{% if is_incremental () %}
WHERE
  filename NOT IN (
    SELECT
      filename
    FROM
      {{this}}
  ) 
{% endif %}