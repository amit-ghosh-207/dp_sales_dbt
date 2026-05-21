{{
    config (
      unique_key = ["weather_hash_diff", "source_file_name"]
    )
}}
with
  cte_raw_weather as (
    select
      weather_hash_diff,
      cast("date" as date) as weather_date,
      temperature::decimal(15, 1) as temperature,
      precipitation::decimal(15, 1) as precipitation,
      city,
      filename,
      load_ts as raw_load_ts
    from
      {{ ref('raw_weather') }}
  )
select
  weather_hash_diff,
  weather_date,
  temperature,
  precipitation,
  city,
  filename as source_file_name,
  get_current_timestamp() as load_ts
from cte_raw_weather

{% if is_incremental () %}
where
  raw_load_ts > (
    select
      max(load_ts)
    from
      {{this}}
  ) 
{% endif %}