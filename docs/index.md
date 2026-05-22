# Model Inventory

### Staging Layer
- **stg_customer**: Profiles and contact information.
- **stg_product**: Core product attributes.
- **stg_product_category**: Categorization and stock levels.
- **stg_sales**: Raw transactional data.
- **stg_subscription**: Plan types and statuses.
- **stg_weather**: Temperature and precipitation data.
- **stg_customer_interaction**: Event-stream data.

### Mart Layer
**Dimensions:** `dim_date`, `dim_customer`, `dim_product`.  
**Facts:** `fact_sales`, `fact_customer_interaction`, `fact_weather`, `fact_review_order`.  
**Aggregates:** `agg_daily_revenue`, `agg_customer_order`, `agg_monthly_revenue_by_payment_method`, `agg_payment_method_monthly_revenue`, `agg_monthly_sales_metrics`.

---

## Model Relationship Summary

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

## Data Flow Diagram

The following diagram illustrates the lineage of data from the staging layer through to the dimensions, facts, and summary aggregates in the mart layer.

```mermaid
graph LR
    subgraph Staging
        stg_sales[stg_sales]
        stg_customer[stg_customer]
        stg_product[stg_product]
        stg_weather[stg_weather]
        stg_interaction[stg_customer_interaction]
    end

    subgraph Mart_Dimensions
        dim_date[dim_date]
        dim_customer[dim_customer]
        dim_product[dim_product]
    end

    subgraph Mart_Facts
        fact_sales[fact_sales]
        fact_weather[fact_weather]
        fact_interaction[fact_customer_interaction]
        fact_review[fact_review_order]
    end

    subgraph Mart_Aggregates
        agg_daily[agg_daily_revenue]
        agg_cust_order[agg_customer_order]
        agg_pay_method[agg_monthly_revenue_by_payment_method]
        agg_pay_month[agg_payment_method_monthly_revenue]
        agg_metrics[agg_monthly_sales_metrics]
    end

    stg_sales --> fact_sales
    stg_customer --> dim_customer
    stg_product --> dim_product
    stg_weather --> fact_weather
    stg_interaction --> fact_interaction
    fact_sales --> fact_review
    fact_sales --> agg_daily
    dim_date --> agg_daily
    fact_sales --> agg_cust_order
    dim_customer --> agg_cust_order
    fact_sales --> agg_pay_method
    fact_sales --> agg_pay_month
    dim_product --> agg_pay_month
    dim_date --> agg_pay_month
    agg_pay_month --> agg_metrics
```

## UML


```mermaid
classDiagram
    class dim_date {
        +date_key : DATE (PK)
        month_key : STRING
        quarter_key : INT
        year_key : INT
        day_of_week : INT
    }

    class dim_customer {
        +customer_id : INT (PK)
        customer_name : STRING
        valid_from : TIMESTAMP
        valid_to : TIMESTAMP
        status : STRING
    }

    class dim_product {
        +product_id : INT (PK)
        product_name : STRING
        product_category_id : STRING
    }

    class fact_sales {
        +order_id : INT (PK)
        +product_id : INT (FK)
        +customer_id : INT (FK)
        +order_date : DATE (FK)
        order_amount : FLOAT
        order_quantity : INT
        payment_method : STRING
        discount_applied : FLOAT
        shipping_cost : FLOAT
    }

    class fact_customer_interaction {
        +customer_id : INT (FK)
        +product_id : INT (FK)
        interaction_type : STRING
        interaction_ts : TIMESTAMP
    }

    class fact_weather {
        +weather_date : DATE (FK)
        +city : STRING (PK)
        temperature : FLOAT
        precipitation : FLOAT
    }

    class fact_review_order {
        +order_id : INT (PK)
        total_order_amount : FLOAT
        discount_pct : FLOAT
        shipping_cost_pct : FLOAT
    }

    class agg_customer_segmentation {
        +customer_id : INT (FK)
        total_order_amount : FLOAT
        total_order_count : INT
        customer_tier : STRING
    }

    class agg_daily_revenue {
        +order_date : DATE (FK)
        total_order_amount : FLOAT
        order_count : INT
        unique_customer_count : INT
    }

    class agg_monthly_revenue_by_payment_method {
        +month_key : STRING (FK)
        +product_category_id : STRING (FK)
        +payment_method : STRING (PK)
        total_monthly_order_amount : FLOAT
        percentage_share : FLOAT
    }

    class agg_monthly_sales_metrics {
        +month_key : STRING (FK)
        +product_category_id : STRING (FK)
        total_revenue : FLOAT
        quarterly_total_revenue : FLOAT
        best_monthly_revenue_ind : BOOLEAN
    }

    %% Relationships
    fact_sales --> dim_date : order_date
    fact_sales --> dim_customer : customer_id
    fact_sales --> dim_product : product_id

    fact_customer_interaction --> dim_customer : customer_id
    fact_customer_interaction --> dim_product : product_id

    fact_weather --> dim_date : weather_date

    fact_review_order ..> fact_sales : filters

    agg_customer_segmentation --> dim_customer : customer_id
    agg_customer_segmentation ..> fact_sales : aggregates

    agg_daily_revenue --> dim_date : order_date
    agg_daily_revenue ..> fact_sales : aggregates

    agg_monthly_revenue_by_payment_method --> dim_date : month_key
    agg_monthly_revenue_by_payment_method --> dim_product : product_category_id
    agg_monthly_revenue_by_payment_method ..> fact_sales : aggregates

    agg_monthly_sales_metrics --> dim_date : month_key
    agg_monthly_sales_metrics ..> agg_monthly_revenue_by_payment_method : calculates growth

```

## Data Mapping & Transformations

The following table provides a detailed lineage of the transformations applied to the data as it moves from the staging layer into the final mart models.

+ +{{ read_csv('../docs/mart_layer_column_mapping.csv') }}
