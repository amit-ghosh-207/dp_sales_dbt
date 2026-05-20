Model Relationship Summary

Based on the provided SQL and YAML configurations, here is how the core mart models interact:

Sales & Revenue Flow:

fact_sales is the central source for most aggregates.
agg_payment_method_monthly_revenue joins fact_sales with dim_date and dim_product to create a multifaceted view of revenue.
agg_monthly_sales_metrics builds directly on top of the monthly revenue aggregate to calculate window-based metrics like quarterly totals and performance indicators.
Customer Insights:

agg_customer_order performs a RIGHT JOIN between fact_sales and dim_customer to ensure all customers are represented (even those without sales) and classifies them into value tiers.
Data Quality & Review:

fact_review_order acts as a filtered view of fact_sales, flagging records that exceed business logic thresholds for discounts and shipping costs.
Temporal Dimensions:

dim_date is a standalone dimension generated via a recursive range, used by revenue models to provide month_key and quarter_key context.
External Factors:

fact_weather and fact_customer_interaction are currently leaf models in the mart layer, processed from staging but not yet joined into the primary sales aggregates in the provided files.

```mermaid
graph TD
    %% Raw Layer
    subgraph Raw_Layer [Raw Layer]
        R_C[raw_customer]
        R_P[raw_product]
        R_PC[raw_product_category]
        R_S[raw_sales]
        R_SUB[raw_subscription]
        R_W[raw_weather]
        R_CI[raw_customer_interaction]
    end

    %% Staging Layer
    subgraph Staging_Layer [Staging Layer]
        S_C[stg_customer]
        S_P[stg_product]
        S_PC[stg_product_category]
        S_S[stg_sales]
        S_SUB[stg_subscription]
        S_W[stg_weather]
        S_CI[stg_customer_interaction]
    end

    %% Mart Layer
    subgraph Mart_Layer [Mart Layer]
        D_DATE[dim_date]
        D_CUST[dim_customer]
        D_PROD[dim_product]
        
        F_S[fact_sales]
        F_W[fact_weather]
        F_CI[fact_customer_interaction]
        F_RO[fact_review_order]

        A_CO[agg_customer_order]
        A_PMO[agg_payment_method_order]
        A_PMMR[agg_payment_method_monthly_revenue]
        A_MSM[agg_monthly_sales_metrics]
        A_DR[agg_daily_revenue]
    end

    %% Lineage Connections
    R_C --> S_C
    R_P --> S_P
    R_PC --> S_PC
    R_S --> S_S
    R_SUB --> S_SUB
    R_W --> S_W
    R_CI --> S_CI

    S_C --> D_CUST
    S_P --> D_PROD
    S_S --> F_S
    S_W --> F_W
    S_CI --> F_CI

    F_S --> F_RO
    F_S --> A_CO
    D_CUST --> A_CO

    F_S --> A_PMO
    
    F_S --> A_PMMR
    D_DATE --> A_PMMR
    D_PROD --> A_PMMR

    A_PMMR --> A_MSM
    D_DATE --> A_MSM

    F_S --> A_DR
```
+## Data Mapping & Transformations + +The following table provides a detailed lineage of the transformations applied to the data as it moves from the staging layer into the final mart models. + +{{ read_csv('../docs/mart_layer_column_mapping.csv') }}

