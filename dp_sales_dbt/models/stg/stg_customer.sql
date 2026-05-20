{{
    config (
      unique_key = ["customer_hash_diff", "source_file_name"],
      tags = ["core", "events"]
    )
}}
WITH
  cte_raw_customer AS (
    SELECT
      customer_hash_diff,
      customer_id,
      customer_name,
      customer_email, 
      CAST(start_date AS DATE) as start_date,
      CAST(end_date AS DATE) as end_date,
      status,
      filename,
      load_ts as raw_load_ts
    FROM
      {{ ref('raw_customer') }}
  )
SELECT
  customer_hash_diff,
  customer_id,
  customer_name,
  customer_email, 
  start_date,
  end_date,
  status,
  filename as source_file_name,
  get_current_timestamp() AS load_ts
FROM cte_raw_customer

{% if is_incremental () %}
WHERE
  raw_load_ts > (
    SELECT
      max(load_ts)
    FROM
      {{this}}
  ) 
{% endif %}