

{{
    config (
      unique_key = ["weather_date", "city"]
    )
}}

select
  weather_date,
  temperature,
  precipitation,
  city,
  get_current_timestamp() AS load_ts
from {{ ref('stg_weather') }}

{% if is_incremental () %}
where
  weather_date = '{{ dbt_airflow_macros.ds(timezone=none) }}'::date
{% endif %}