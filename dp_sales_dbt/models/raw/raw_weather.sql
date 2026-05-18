{{
    config (
      unique_key = "weather_hash_diff",
      tags = ["core", "events"]
    )
}}
WITH
  cte_raw_weather AS (
    SELECT
      *,
      get_current_timestamp() AS load_ts
    FROM
      {{ source ('external_source', 'weather') }}
  )
SELECT
  MD5(
    concat_ws(
      '|',
      COALESCE(date, 'default_value'),
      COALESCE(temperature, 'default_value'),
      COALESCE(precipitation, 'default_value'),
      COALESCE(city, 'default_value')
    )
  ) AS weather_hash_diff,
  *
FROM cte_raw_weather

{% if is_incremental () %}
WHERE
  filename NOT IN (
    SELECT
      filename
    FROM
      {{this}}
  ) 
{% endif %}