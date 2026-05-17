{{
    config (
      unique_key = "raw_customer_hash_key",
      tags = ["core", "events"]
    )
}}
WITH
  cte_raw_customer AS (
    SELECT
      *,
      get_current_timestamp() AS load_ts
    FROM
      {{ source ('external_source', 'customer') }}
  )
SELECT
  MD5(
    concat_ws(
      '|',
      COALESCE(customer_id, 'default_value'),
      COALESCE(customer_name, 'default_value'),
      COALESCE(customer_email, 'default_value'),
      COALESCE(start_date, 'default_value'),
      COALESCE(end_date, 'default_value'),
      COALESCE(status, 'default_value'),
      filename,
      load_ts
    )
  ) AS raw_customer_hash_key,
  *
FROM cte_raw_customer

{% if is_incremental () %}
WHERE
  filename NOT IN (
    SELECT
      filename
    FROM
      {{this}}
  ) 
{% endif %}