{{
    config (
      unique_key = "product_hash_diff"
    )
}}
with
  cte_raw_product as (
    select
      *,
      get_current_timestamp() as load_ts
    from
      {{ source ('external_source', 'product') }}
    where not contains(filename, 'product_category')
  )
select
  md5(
    concat_ws(
      '|',
      coalesce(product_id, 'default_value'),
      coalesce(product_name, 'default_value'),
      coalesce(product_category_id, 'default_value')
    )
  ) as product_hash_diff,
  *
from cte_raw_product

{% if is_incremental () %}
where
  filename not in (
    select
      filename
    from
      {{this}}
  )
{% endif %}
