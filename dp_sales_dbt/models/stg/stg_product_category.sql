{{
    config (
      unique_key = ["product_category_hash_diff", "filename"],
      tags = ["core", "events"]
    )
}}
WITH
  cte_raw_product_category AS (
    SELECT
      product_category_hash_diff,
      product_id,
      category_id,
      category_name,
      subcategory,
      brand,
      supplier_id,
      cost_price::DECIMAL(15, 2) as cost_price,
      retail_price::DECIMAL(15, 2) as retail_price,
      margin_percent::DECIMAL(15, 2) as margin_percent,
      stock_level::INTEGER as stock_level,
      reorder_point::INTEGER as reorder_point,
      discontinued::BOOLEAN as discontinued,
      CAST(launch_date AS DATE) as launch_date,
      CAST(last_updated AS DATE) as last_updated_date,
      filename,
      load_ts as raw_load_ts
    FROM
      {{ ref('raw_product_category') }}
  )
SELECT
  product_category_hash_diff,
  product_id,
  category_id,
  category_name,
  subcategory,
  brand,
  supplier_id,
  cost_price,
  retail_price,
  margin_percent,
  stock_level,
  reorder_point,
  discontinued,
  launch_date,
  last_updated_date,
  filename,
  get_current_timestamp() AS load_ts
FROM cte_raw_product_category

{% if is_incremental () %}
WHERE
  raw_load_ts > (
    SELECT
      load_ts
    FROM
      {{this}}
  ) 
{% endif %}