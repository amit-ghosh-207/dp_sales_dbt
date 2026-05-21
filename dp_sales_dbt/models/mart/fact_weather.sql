{{
    config (
      unique_key = ["weather_date", "city"]
    )
}}

SELECT
  weather_date,
  temperature,
  precipitation,
  city,
  get_current_timestamp() AS load_ts
FROM {{ ref('stg_weather') }}

{% if is_incremental () %}
WHERE
  weather_date = '{{ dbt_airflow_macros.ds(timezone=none) }}'::DATE
{% endif %}