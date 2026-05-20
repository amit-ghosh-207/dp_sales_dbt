{{
    config (
      unique_key = ["month_key", "product_category_id"],
      tags = ["core", "events"]
    )
}}

WITH cte_agg_revenue as
    (
        SELECT
            dd.month_key,
            dp.product_category_id,
            sum(fs.order_amount) AS total_revenue,
            stddev_pop(fs.order_amount)/avg(fs.order_amount)as monthly_order_volatility,
            coalesce(
                sum(
                    CASE
                        WHEN lower(fs.payment_method) = 'credit_card' THEN fs.order_amount
                    END
                ),
                0
            ) AS total_revenue_credit_card,
            coalesce(
                sum(
                    CASE
                        WHEN lower(fs.payment_method) = 'bank_transfer' THEN fs.order_amount
                    END
                ),
                0
            ) AS total_revenue_bank_transfer,
            coalesce(
                sum(
                    CASE
                        WHEN lower(fs.payment_method) = 'paypal' THEN fs.order_amount
                    END
                ),
                0
            ) AS total_revenue_paypal,
            coalesce(
                sum(
                    CASE
                        WHEN lower(fs.payment_method) = 'debit_card' THEN fs.order_amount
                    END
                ),
                0
            ) AS total_revenue_debit_card,
            round(if (
                total_revenue = 0,
                0,
                total_revenue_credit_card * 100 / total_revenue
            ), 2) AS total_revenue_credit_card_pct,
            round(if (
                total_revenue = 0,
                0,
                total_revenue_bank_transfer * 100 / total_revenue
            ), 2) AS total_revenue_bank_transfer_pct,
            round(if (
                total_revenue = 0,
                0,
                total_revenue_paypal * 100 / total_revenue
            ), 2) AS total_revenue_paypal_pct,
            round(if (
                total_revenue = 0,
                0,
                total_revenue_debit_card * 100 / total_revenue
            ), 2) AS total_revenue_debit_card_pct,
        FROM
            {{ ref('fact_sales') }} AS fs
            INNER JOIN {{ ref('dim_date') }} AS dd ON fs.order_date = dd.date_key
            INNER JOIN {{ ref('dim_product') }} AS dp ON fs.product_id = dp.product_id
        GROUP BY
            dd.month_key,
            dp.product_category_id
    )
select 
    month_key,
    product_category_id,
    total_revenue,
    monthly_order_volatility,
    total_revenue_credit_card,
    total_revenue_bank_transfer,
    total_revenue_paypal,
    total_revenue_debit_card,
    total_revenue_credit_card_pct,
    total_revenue_bank_transfer_pct,
    total_revenue_paypal_pct,
    total_revenue_debit_card_pct,
    get_current_timestamp() AS load_ts
from cte_agg_revenue

{% if is_incremental () %}
WHERE
  month_key in (
    select month_key from {{ ref('dim_date') }}
    where date_key = '{{ dbt_airflow_macros.ds(timezone=none) }}'::DATE
  )
{% endif %}