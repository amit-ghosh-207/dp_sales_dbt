{{
    config (
      unique_key = ["product_category_hash_diff", "source_file_name"]
    )
}}
with
  cte_raw_product_category as (
    select
      product_category_hash_diff,
      product_id,
      category_id,
      category_name,
      subcategory,
      brand,
      supplier_id,
      cost_price::decimal(15, 2) as cost_price,
      retail_price::decimal(15, 2) as retail_price,
      margin_percent::decimal(15, 2) as margin_percent,
      stock_level::integer as stock_level,
      reorder_point::integer as reorder_point,
      discontinued::boolean as discontinued,
      cast(launch_date as date) as launch_date,
      cast(last_updated as date) as source_last_updated_date,
      filename,
      load_ts as raw_load_ts
    from
      {{ ref('raw_product_category') }}
  )
select
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
  source_last_updated_date,
  filename as source_file_name,
  get_current_timestamp() as load_ts
from cte_raw_product_category

{% if is_incremental () %}
where
  raw_load_ts > (
    select
      max(load_ts)
    from
      {{this}}
  )
{% endif %}
