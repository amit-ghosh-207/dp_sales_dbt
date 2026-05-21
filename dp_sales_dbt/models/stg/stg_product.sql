{{
    config (
      unique_key = ["product_hash_diff", "source_file_name"]
    )
}}
WITH
  cte_raw_product AS (
    SELECT
      product_hash_diff,
      product_id,
      product_name,
      product_category_id,
      filename,
      load_ts as raw_load_ts
    FROM
      {{ ref('raw_product') }}
  )
SELECT
  product_hash_diff,
  product_id,
  product_name,
  product_category_id,
  filename as source_file_name,
  get_current_timestamp() AS load_ts
FROM cte_raw_product

{% if is_incremental () %}
WHERE
  raw_load_ts > (
    SELECT
      max(load_ts)
    FROM
      {{this}}
  ) 
{% endif %}