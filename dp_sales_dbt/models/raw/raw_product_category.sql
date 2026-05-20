{{
    config (
      unique_key = "product_category_hash_diff",
      tags = ["core", "events"]
    )
}}
WITH
  cte_raw_product_category AS (
    SELECT
      *,
      get_current_timestamp() AS load_ts
    FROM
      {{ source ('external_source', 'product_category') }}
  )
SELECT
  MD5(
    concat_ws(
      '|',
      COALESCE(product_id, 'default_value'),
      COALESCE(category_id, 'default_value'),
      COALESCE(category_name, 'default_value'),
      COALESCE(subcategory, 'default_value'),
      COALESCE(brand, 'default_value'),
      COALESCE(supplier_id, 'default_value'),
      COALESCE(cost_price, 'default_value'),
      COALESCE(retail_price, 'default_value'),
      COALESCE(margin_percent, 'default_value'),
      COALESCE(stock_level, 'default_value'),
      COALESCE(reorder_point, 'default_value'),
      COALESCE(discontinued, 'default_value'),
      COALESCE(launch_date, 'default_value'),
      COALESCE(last_updated, 'default_value')
    )
  ) AS product_category_hash_diff,
  *
FROM cte_raw_product_category

{% if is_incremental () %}
WHERE
  filename NOT IN (
    SELECT
      filename
    FROM
      {{this}}
  ) 
{% endif %}