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

SELECT
  customer_id,
  product_id,
  interaction_type,
  interaction_ts,
  get_current_timestamp() AS load_ts
FROM {{ ref('stg_customer_interaction') }}

{% if is_incremental () %}
WHERE 1 = 1
and interaction_ts::DATE between 
'{{ dbt_airflow_macros.ds(timezone=none) }}'::DATE  - INTERVAL 3 DAY  
and '{{ dbt_airflow_macros.ds(timezone=none) }}'::DATE
{% endif %}