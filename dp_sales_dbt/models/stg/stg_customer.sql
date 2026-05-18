{{
    config (
      unique_key = "customer_hash_diff",
      tags = ["core", "events"]
    )
}}
WITH
  cte_raw_customer AS (
    SELECT
      customer_id,
      customer_name,
      customer_email,
      start_date,
      end_date,
      status,
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
  ) AS customer_hash_diff,
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