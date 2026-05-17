{{
    config (
      unique_key = "raw_subscription_hash_key",
      tags = ["core", "events"]
    )
}}
WITH
  cte_raw_subscription AS (
    SELECT
      *,
      get_current_timestamp() AS load_ts
    FROM
      {{ source ('external_source', 'subscription') }}
  )
SELECT
  MD5(
    concat_ws(
      '|',
      COALESCE(customer_id, 'default_value'),
      COALESCE(subscription_id, 'default_value'),
      COALESCE(plan_type, 'default_value'),
      COALESCE(subscription_start_date, 'default_value'),
      COALESCE(subscription_end_date, 'default_value'),
      COALESCE(monthly_fee, 'default_value'),
      COALESCE(status, 'default_value'),
      filename,
      load_ts
    )
  ) AS raw_subscription_hash_key,
  *
FROM cte_raw_subscription

{% if is_incremental () %}
WHERE
  filename NOT IN (
    SELECT
      filename
    FROM
      {{this}}
  ) 
{% endif %}