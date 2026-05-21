{{
    config (
      unique_key = ["weather_hash_diff", "source_file_name"]
    )
}}
WITH
  cte_raw_weather AS (
    SELECT
      weather_hash_diff,
      CAST("date" AS DATE) as weather_date,
      temperature::DECIMAL(15, 1) as temperature,
      precipitation::DECIMAL(15, 1) as precipitation,
      city,
      filename,
      load_ts as raw_load_ts
    FROM
      {{ ref('raw_weather') }}
  )
SELECT
  weather_hash_diff,
  weather_date,
  temperature,
  precipitation,
  city,
  filename as source_file_name,
  get_current_timestamp() AS load_ts
FROM cte_raw_weather

{% if is_incremental () %}
WHERE
  raw_load_ts > (
    SELECT
      max(load_ts)
    FROM
      {{this}}
  ) 
{% endif %}