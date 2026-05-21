{{
    config (
      unique_key = ["product_hash_diff", "source_file_name"]
    )
}}
with
  cte_raw_product as (
    select
      product_hash_diff,
      product_id,
      product_name,
      product_category_id,
      filename,
      load_ts as raw_load_ts
    from
      {{ ref('raw_product') }}
  )
select
  product_hash_diff,
  product_id,
  product_name,
  product_category_id,
  filename as source_file_name,
  get_current_timestamp() as load_ts
from cte_raw_product

{% if is_incremental () %}
where
  raw_load_ts > (
    select
      max(load_ts)
    from
      {{this}}
  )
{% endif %}
