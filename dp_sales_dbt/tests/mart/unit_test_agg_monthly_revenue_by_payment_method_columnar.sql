-- depends_on: {{ ref('fact_sales') }}
-- depends_on: {{ ref('dim_date') }}
-- depends_on: {{ ref('dim_product') }}

{{ config(tags=['unit-test']) }}

{% call dbt_unit_testing.test('agg_monthly_revenue_by_payment_method_columnar', 'test_payment_method_pivoted_percentages') %}

  {% call dbt_unit_testing.mock_ref('fact_sales') %}
    select 1 as order_id, '2024-01-01'::DATE as order_date, 101 as product_id, 1 as order_quantity, 100.0 as order_amount, 'credit_card' as payment_method
    union all
    select 2 as order_id, '2024-01-15'::DATE as order_date, 101 as product_id, 3 as order_quantity, 300.0 as order_amount, 'paypal' as payment_method
  {% endcall %}

  {% call dbt_unit_testing.mock_ref('dim_date') %}
    select '2024-01-01'::DATE as date_key, '202401' as month_key
    union all
    select '2024-01-15'::DATE as date_key, '202401' as month_key
  {% endcall %}

  {% call dbt_unit_testing.mock_ref('dim_product') %}
    select 101 as product_id, 'CAT_A' as product_category_id
  {% endcall %}

  {% call dbt_unit_testing.expect() %}
    select
        '202401' as month_key,
        'CAT_A' as product_category_id,
        2 as order_count,
        200.0 as avg_order_amount,
        400.0 as total_monthly_order_amount,
        4 as total_monthly_order_quantity,
        100.0 as total_credit_card_order_amount,
        0.0 as total_debit_card_order_amount,
        300.0 as total_paypal_order_amount,
        0.0 as total_bank_transfer_order_amount,
        25.0 as credit_card_percentage_share,
        0.0 as debit_card_percentage_share,
        75.0 as paypal_percentage_share,
        0.0 as bank_transfer_percentage_share
  {% endcall %}
{% endcall %}