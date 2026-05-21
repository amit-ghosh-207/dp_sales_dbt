{{
    config (
      unique_key = ["subscription_hash_diff", "source_file_name"]
    )
}}
with
  cte_raw_subscription as (
    select
      subscription_hash_diff,
      customer_id,
      subscription_id,
      plan_type,
      cast(subscription_start_date as date) as subscription_start_date,
      cast(subscription_end_date as date) as subscription_end_date,
      monthly_fee::decimal(15, 2) as monthly_fee,
      status,
      filename,
      load_ts as raw_load_ts
    from
      {{ ref('raw_subscription') }}
  )
select
  subscription_hash_diff,
  customer_id,
  subscription_id,
  plan_type,
  subscription_start_date,
  subscription_end_date,
  monthly_fee,
  status,
  filename as source_file_name,
  get_current_timestamp() as load_ts
from cte_raw_subscription

{% if is_incremental () %}
where
  raw_load_ts > (
    select
      max(load_ts)
    from
      {{this}}
  )
{% endif %}
