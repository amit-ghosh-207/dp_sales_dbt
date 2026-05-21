{{
    config (
      unique_key = ["subscription_hash_diff", "source_file_name"]
    )
}}
WITH
  cte_raw_subscription AS (
    SELECT
      subscription_hash_diff,
      customer_id,
      subscription_id,
      plan_type,
      CAST(subscription_start_date AS DATE) as subscription_start_date,
      CAST(subscription_end_date AS DATE) as subscription_end_date,
      monthly_fee::DECIMAL(15, 2) as monthly_fee,
      status,
      filename,
      load_ts as raw_load_ts
    FROM
      {{ ref('raw_subscription') }}
  )
SELECT
  subscription_hash_diff,
  customer_id,
  subscription_id,
  plan_type,
  subscription_start_date,
  subscription_end_date,
  monthly_fee,
  status,
  filename as source_file_name,
  get_current_timestamp() AS load_ts
FROM cte_raw_subscription

{% if is_incremental () %}
WHERE
  raw_load_ts > (
    SELECT
      max(load_ts)
    FROM
      {{this}}
  ) 
{% endif %}