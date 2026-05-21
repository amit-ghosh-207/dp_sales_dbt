-- depends_on: {{ ref('fact_sales') }}
-- depends_on: {{ ref('dim_date') }}
-- depends_on: {{ ref('dim_product') }}

{{ config(tags=['unit-test']) }}

{% call dbt_unit_testing.test('agg_payment_method_monthly_revenue', 'test_payment_method_split_and_percentages') %}

  {% call dbt_unit_testing.mock_ref('fact_sales') %}
    select '2024-01-01'::DATE as order_date, 1 as product_id, 100.0 as order_amount, 'credit_card' as payment_method
    union all
    select '2024-01-15'::DATE as order_date, 1 as product_id, 300.0 as order_amount, 'paypal' as payment_method
  {% endcall %}

  {% call dbt_unit_testing.mock_ref('dim_date') %}
    select '2024-01-01'::DATE as date_key, '202401' as month_key
    union all
    select '2024-01-15'::DATE as date_key, '202401' as month_key
  {% endcall %}

  {% call dbt_unit_testing.mock_ref('dim_product') %}
    select 1 as product_id, 'CAT_A' as product_category_id
  {% endcall %}

  {% call dbt_unit_testing.expect() %}
    select
        '202401' as month_key,
        'CAT_A' as product_category_id,
        400.0 as total_revenue,
        100.0 as total_revenue_credit_card,
        300.0 as total_revenue_paypal,
        25.0 as total_revenue_credit_card_pct,
        75.0 as total_revenue_paypal_pct
  {% endcall %}
{% endcall %}
