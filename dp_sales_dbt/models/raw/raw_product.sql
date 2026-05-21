{{
    config (
      unique_key = "product_hash_diff"
    )
}}
WITH
  cte_raw_product AS (
    SELECT
      *,
      get_current_timestamp() AS load_ts
    FROM
      {{ source ('external_source', 'product') }}
    WHERE NOT contains(filename, 'product_category')
  )
SELECT
  MD5(
    concat_ws(
      '|',
      COALESCE(product_id, 'default_value'),
      COALESCE(product_name, 'default_value'),
      COALESCE(product_category_id, 'default_value')
    )
  ) AS product_hash_diff,
  *
FROM cte_raw_product

{% if is_incremental () %}
WHERE
  filename NOT IN (
    SELECT
      filename
    FROM
      {{this}}
  ) 
{% endif %}