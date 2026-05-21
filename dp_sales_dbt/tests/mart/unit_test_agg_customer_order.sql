-- depends_on: {{ ref('fact_sales') }}
-- depends_on: {{ ref('dim_customer') }}

{{ config(tags=['unit-test']) }}

{% call dbt_unit_testing.test('agg_customer_order', 'test_customer_segmentation_logic') %}
  
  {% call dbt_unit_testing.mock_ref('fact_sales') %}
    select 1 as customer_id, 101 as order_id, 300 as order_amount
    union all
    select 1 as customer_id, 102 as order_id, 300 as order_amount -- Total 600: Medium
    union all
    select 2 as customer_id, 201 as order_id, 1200 as order_amount -- Total 1200: High
    union all
    select 3 as customer_id, 301 as order_id, 100 as order_amount  -- Total 100: Low
    union all
    select 4 as customer_id, 501 as order_id, 1000 as order_amount  -- Total 1000: High
  {% endcall %}

  {% call dbt_unit_testing.mock_ref('dim_customer') %}
    -- Use a fixed date that matches the expected ds macro value for the test
    select 1 as customer_id, 'Cust A' as customer_name, '2000-01-01' as valid_from, '9999-12-31' as valid_to, 'active' as status
    union all
    select 2 as customer_id, 'Cust B' as customer_name, '2000-01-01' as valid_from, '9999-12-31' as valid_to, 'active' as status
    union all
    select 3 as customer_id, 'Cust C' as customer_name, '2000-01-01' as valid_from, '9999-12-31' as valid_to, 'active' as status
    union all
    --Customers with 'candelled' status will be excluded from the result
    select 4 as customer_id, 'Cust D' as customer_name, '2000-01-01' as valid_from, '9999-12-31' as valid_to, 'cancelled' as status
  {% endcall %}

  {% call dbt_unit_testing.expect() %}
    select 1 as customer_id, 'Cust A' as customer_name, 600.0 as total_order_amount, 2 as total_order_count, 'Medium Value' as customer_tier
    union all
    select 2 as customer_id, 'Cust B' as customer_name, 1200.0 as total_order_amount, 1 as total_order_count, 'High Value' as customer_tier
    union all
    select 3 as customer_id, 'Cust C' as customer_name, 100.0 as total_order_amount, 1 as total_order_count, 'Low Value' as customer_tier
  {% endcall %}

{% endcall %}