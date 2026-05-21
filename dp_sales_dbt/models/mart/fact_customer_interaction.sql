{{
    config (
      unique_key = [
        "customer_id", 
        "product_id", 
        "interaction_type", 
        "interaction_ts"
      ]
    )
}}

select
  customer_id,
  product_id,
  interaction_type,
  interaction_ts,
  get_current_timestamp() as load_ts
from {{ ref('stg_customer_interaction') }}

{% if is_incremental () %}
where 1 = 1
and interaction_ts::date between 
'{{ dbt_airflow_macros.ds(timezone=none) }}'::date  - interval 3 day  
and '{{ dbt_airflow_macros.ds(timezone=none) }}'::date
{% endif %}