{{
    config (
      unique_key = "subscription_hash_diff"
    )
}}
with
  cte_raw_subscription as (
    select
      *,
      get_current_timestamp() as load_ts
    from
      {{ source ('external_source', 'subscription') }}
  )
select
  md5(
    concat_ws(
      '|',
      coalesce(customer_id, 'default_value'),
      coalesce(subscription_id, 'default_value'),
      coalesce(plan_type, 'default_value'),
      coalesce(subscription_start_date, 'default_value'),
      coalesce(subscription_end_date, 'default_value'),
      coalesce(monthly_fee, 'default_value')
    )
  ) as subscription_hash_diff,
  *
from cte_raw_subscription

{% if is_incremental () %}
where
  filename not in (
    select
      filename
    from
      {{this}}
  )
{% endif %}
