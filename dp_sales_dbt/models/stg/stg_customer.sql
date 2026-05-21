{{
    config (
      unique_key = ["customer_hash_diff", "source_file_name"]
    )
}}
with
  cte_raw_customer as (
    select
      customer_hash_diff,
      customer_id,
      customer_name,
      customer_email, 
      cast(start_date as date) as start_date,
      cast(end_date as date) as end_date,
      status,
      filename,
      load_ts as raw_load_ts
    from
      {{ ref('raw_customer') }}
  )
select
  customer_hash_diff,
  customer_id,
  customer_name,
  customer_email, 
  start_date,
  end_date,
  status,
  filename as source_file_name,
  get_current_timestamp() as load_ts
from cte_raw_customer

{% if is_incremental () %}
where
  raw_load_ts > (
    select
      max(load_ts)
    from
      {{this}}
  ) 
{% endif %}