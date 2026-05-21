{{
    config (
      materialized = "table"
    )
}}

select
    dc.customer_id,
    dc.customer_name,
    coalesce(sum(fs.order_amount), 0) as total_order_amount,
    coalesce(count(distinct fs.order_id), 0) as total_order_count,
    case
        when total_order_amount < 500 then 'Low Value'
        when total_order_amount < 1000 then 'Medium Value'
        else 'High Value'
    end as customer_tier
from
    {{ ref('fact_sales') }} as fs
    right join {{ ref('dim_customer') }} as dc on fs.customer_id = dc.customer_id

where 1 = 1
    and '{{ dbt_airflow_macros.ds(timezone=none) }}'::date between dc.valid_from::date and dc.valid_to::date
    and dc.status <> 'cancelled'

group by
    dc.customer_id,
    dc.customer_name