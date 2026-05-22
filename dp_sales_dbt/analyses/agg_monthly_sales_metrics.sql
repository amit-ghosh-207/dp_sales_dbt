with cte_qarters as(
    select distinct
        month_key,
        quarter_key
    from
        {{ ref('dim_date') }}
),
cte_agg_revenue as
    (
        select
            dd.month_key,
            dp.product_category_id,
            sum(fs.order_amount) as total_revenue,
            stddev_pop(fs.order_amount)/avg(fs.order_amount) as monthly_order_volatility,
            coalesce(
                sum(
                    case
                        when lower(fs.payment_method) = 'credit_card' then fs.order_amount
                    end
                ),
                0
            ) as total_revenue_credit_card,
            coalesce(
                sum(
                    case
                        when lower(fs.payment_method) = 'bank_transfer' then fs.order_amount
                    end
                ),
                0
            ) as total_revenue_bank_transfer,
            coalesce(
                sum(
                    case
                        when lower(fs.payment_method) = 'paypal' then fs.order_amount
                    end
                ),
                0
            ) as total_revenue_paypal,
            coalesce(
                sum(
                    case
                        when lower(fs.payment_method) = 'debit_card' then fs.order_amount
                    end
                ),
                0
            ) as total_revenue_debit_card,
            round(if (
                total_revenue = 0,
                0,
                total_revenue_credit_card * 100 / total_revenue
            ), 2) as total_revenue_credit_card_pct,
            round(if (
                total_revenue = 0,
                0,
                total_revenue_bank_transfer * 100 / total_revenue
            ), 2) as total_revenue_bank_transfer_pct,
            round(if (
                total_revenue = 0,
                0,
                total_revenue_paypal * 100 / total_revenue
            ), 2) as total_revenue_paypal_pct,
            round(if (
                total_revenue = 0,
                0,
                total_revenue_debit_card * 100 / total_revenue
            ), 2) as total_revenue_debit_card_pct,
        from
            {{ ref('fact_sales') }} as fs
            inner join {{ ref('dim_date') }} as dd on fs.order_date = dd.date_key
            inner join {{ ref('dim_product') }} as dp on fs.product_id = dp.product_id
        group by
            dd.month_key,
            dp.product_category_id
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
    cte_agg_revenue as amr
    inner join cte_qarters as dd on amr.month_key = dd.month_key
order by
    amr.month_key,
    amr.product_category_id
