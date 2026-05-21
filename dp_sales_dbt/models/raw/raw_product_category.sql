{{
    config (
      unique_key = "product_category_hash_diff"
    )
}}
with
  cte_raw_product_category as (
    select
      *,
      get_current_timestamp() as load_ts
    from
      {{ source ('external_source', 'product_category') }}
  )
select
  md5(
    concat_ws(
      '|',
      coalesce(product_id, 'default_value'),
      coalesce(category_id, 'default_value'),
      coalesce(category_name, 'default_value'),
      coalesce(subcategory, 'default_value'),
      coalesce(brand, 'default_value'),
      coalesce(supplier_id, 'default_value'),
      coalesce(cost_price, 'default_value'),
      coalesce(retail_price, 'default_value'),
      coalesce(margin_percent, 'default_value'),
      coalesce(stock_level, 'default_value'),
      coalesce(reorder_point, 'default_value'),
      coalesce(discontinued, 'default_value'),
      coalesce(launch_date, 'default_value'),
      coalesce(last_updated, 'default_value')
    )
  ) as product_category_hash_diff,
  *
from cte_raw_product_category

{% if is_incremental () %}
where
  filename not in (
    select
      filename
    from
      {{this}}
  ) 
{% endif %}