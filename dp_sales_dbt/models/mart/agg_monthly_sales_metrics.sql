{{
    config (
      unique_key = ["month_key", "product_category_id"]
    )
}}

with cte_qarters as(
    select distinct
        month_key,
        quarter_key
    from
        {{ ref('dim_date') }}
)
select
    amr.month_key,
    dd.quarter_key,
    amr.product_category_id,
    amr.total_revenue,
    amr.monthly_order_volatility,
    sum(amr.total_revenue) over (
        partition by
            dd.quarter_key,
            amr.product_category_id
        order by
            amr.month_key rows between unbounded preceding
            and current row
    ) as quarterly_total_revenue,
    (
        amr.total_revenue = max(amr.total_revenue) over (
            partition by
                amr.product_category_id
        )
    ) as best_monthly_revenue_ind,
    (
        amr.total_revenue = min(amr.total_revenue) over (
            partition by
                amr.product_category_id
        )
    ) as worst_monthly_revenue_ind,
from
    {{ ref('agg_payment_method_monthly_revenue') }} as amr
    inner join cte_qarters as dd on amr.month_key = dd.month_key

{% if is_incremental () %}
where
  amr.month_key in (
    select month_key from {{ ref('dim_date') }}
    where date_key = '{{ dbt_airflow_macros.ds(timezone=none) }}'::date
  )
{% endif %}
