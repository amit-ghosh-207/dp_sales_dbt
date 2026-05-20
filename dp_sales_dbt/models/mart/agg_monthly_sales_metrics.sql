{{
    config (
      unique_key = ["month_key", "product_category_id"],
      tags = ["core", "events"]
    )
}}

with cte_qarters as(
    SELECT DISTINCT
        month_key,
        quarter_key
    FROM
        {{ ref('dim_date') }}
)
SELECT
    amr.month_key,
    dd.quarter_key,
    amr.product_category_id,
    amr.total_revenue,
    amr.monthly_order_volatility,
    sum(amr.total_revenue) over (
        PARTITION BY
            dd.quarter_key,
            amr.product_category_id
        ORDER BY
            amr.month_key ROWS BETWEEN UNBOUNDED PRECEDING
            AND current row
    ) AS quarterly_total_revenue,
    (
        amr.total_revenue = max(amr.total_revenue) over (
            PARTITION BY
                amr.product_category_id
        )
    ) AS best_monthly_revenue_ind,
    (
        amr.total_revenue = min(amr.total_revenue) over (
            PARTITION BY
                amr.product_category_id
        )
    ) AS worst_monthly_revenue_ind,
FROM
    {{ ref('agg_payment_method_monthly_revenue') }} AS amr
    INNER JOIN cte_qarters AS dd ON amr.month_key = dd.month_key

{% if is_incremental () %}
WHERE
  amr.month_key in (
    select month_key from {{ ref('dim_date') }}
    where date_key = '{{ dbt_airflow_macros.ds(timezone=none) }}'::DATE
  )
{% endif %}
