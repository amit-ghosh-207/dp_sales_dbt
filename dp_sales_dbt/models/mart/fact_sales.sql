{{
    config (
      unique_key = ["order_id", "product_id", "customer_id", "order_date"]
    )
}}

select
    order_id,
    product_id,
    customer_id,
    order_date,
    order_amount,
    order_quantity,
    payment_method,
    discount_applied,
    shipping_cost,
    get_current_timestamp() as load_ts
from {{ ref('stg_sales') }}

{% if is_incremental () %}
where
  order_date = '{{ dbt_airflow_macros.ds(timezone=none) }}'::date
{% endif %}
