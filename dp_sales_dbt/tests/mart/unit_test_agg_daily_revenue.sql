-- depends_on: {{ ref('fact_sales') }}
-- depends_on: {{ ref('dim_date') }}

{{ config(tags=['unit-test']) }}

{% call dbt_unit_testing.test('agg_daily_revenue', 'test_daily_revenue_aggregation_and_missing_dates') %}
  
  {% call dbt_unit_testing.mock_ref('fact_sales') %}
    select '2024-01-01'::DATE as order_date, 1001 as order_id, 10 as customer_id, 50.0 as order_amount
    union all
    select '2024-01-01'::DATE as order_date, 1002 as order_id, 10 as customer_id, 25.0 as order_amount
  {% endcall %}

  {% call dbt_unit_testing.mock_ref('dim_date') %}
    select '2024-01-01'::DATE as date_key
    union all
    select '2024-01-02'::DATE as date_key -- Date with no sales
  {% endcall %}

  {% call dbt_unit_testing.expect() %}
    -- Note: agg_daily_revenue uses right join, so 2024-01-02 should appear with 0s
    select '2024-01-01'::DATE as order_date, 75.0 as total_order_amount, 2 as order_count, 1 as unique_customer_count
    union all
    select '2024-01-02'::DATE as order_date, 0.0 as total_order_amount, 0 as order_count, 0 as unique_customer_count
  {% endcall %}

{% endcall %}