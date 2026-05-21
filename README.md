# dbt Playground

This homework is intended to understand your capability in DBT & SQL. The problem is
posed quite loosely to allow you to solve it in the way you are most comfortable. We will be looking
at the approach used, the code style, structure, and quality as well as testing.
You are evaluated on production readiness, not on writing one model per question.


### Evaluation Criteria
- Data Pipeline & Data Flows
- Perforamance
- Dynamic Development and Best Coding Practices
- Data quality, generic tests & constraints via schema tests
- Documentation & clarity

### Prerequisites

- Python 3.8 or higher
- dbt Core

### Getting Started

- Create a working dbt setup
- The relevant source files should be under files/ directory
- Follow the Questions below and answer based on the files provided.


## Question 1:
Create a dbt model that calculates total revenue by product category for each month. Include basic data transformations and aggregations.

---

## Question 2:
Extend the previous model to handle edge cases where `order_quantity` is zero and calculate the percentage of sales coming from each payment method. Handle null values appropriately.

---

## Question 3:
Create a dbt model that segments customers into tiers based on their total purchase amount:
- "High Value": Total purchases >= $1000
- "Medium Value": Total purchases between $500-$999
- "Low Value": Total purchases < $500

Include customer names and calculate the number of orders per customer.

---

## Question 4:
Create a model that analyzes payment method preferences by calculating:
- Total revenue by payment method
- Average order value by payment method
- Number of orders by payment method
- Percentage distribution of each payment method

---

## Question 5:
Create a dbt model that flags orders for review based on business rules:
- `discount_applied` > 30%
- `shipping_cost` > 10% of `order_amount`
- Handle null values in both `discount_applied` and `shipping_cost`

---

## Question 6:
Analyze seasonal sales patterns by creating a model that shows:
- Monthly sales trends by product category
- Quarter-over-quarter growth rates
- Identify the best and worst performing months for each category
- Calculate the coefficient of variation to measure sales volatility

---

## Question 7:
Create a dbt macro that accepts date range parameters and filters sales data accordingly. Use this macro in a model to calculate daily revenue totals. Handle cases where no data exists for the given date range.
