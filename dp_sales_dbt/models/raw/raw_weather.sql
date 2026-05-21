{{
    config (
      unique_key = "weather_hash_diff"
    )
}}
with
  cte_raw_weather as (
    select
      *,
      get_current_timestamp() as load_ts
    from
      {{ source ('external_source', 'weather') }}
  )
select
  md5(
    concat_ws(
      '|',
      coalesce("date", 'default_value'),
      coalesce(temperature, 'default_value'),
      coalesce(precipitation, 'default_value'),
      coalesce(city, 'default_value')
    )
  ) as weather_hash_diff,
  *
from cte_raw_weather

{% if is_incremental () %}
where
  filename not in (
    select
      filename
    from
      {{this}}
  ) 
{% endif %}