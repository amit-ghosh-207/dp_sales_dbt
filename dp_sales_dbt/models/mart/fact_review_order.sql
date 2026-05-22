{{
    config (
      unique_key = ["order_id"]
    )
}}

select
    order_id,
    sum(order_amount) as total_order_amount,
    sum(coalesce(order_quantity, 0)) as total_order_quantity,
    sum(coalesce(discount_applied, 0)) as total_discount_applied,
    sum(coalesce(shipping_cost, 0)) as total_shipping_cost,
    round((total_discount_applied * 100 / total_order_amount), 2) as discount_pct,
    round((total_shipping_cost * 100 / total_order_amount), 2) as shipping_cost_pct,
    get_current_timestamp() as load_ts
from {{ ref('fact_sales') }}
where 1 = 1
  and order_amount > 0
{% if is_incremental () %}
   and order_date = '{{ dbt_airflow_macros.ds(timezone=none) }}'::date
{% endif %}
group by 
  order_id
having 
  (discount_pct > 30 or shipping_cost_pct> 10)