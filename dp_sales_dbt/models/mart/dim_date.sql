{{
    config (
        materialized = "table"
    )
}}
WITH
    generate_date AS (
        SELECT
            CAST(RANGE AS DATE) AS date_key
        FROM
            RANGE(
                DATE '2023-01-01',
                DATE '2028-12-31',
                INTERVAL 1 DAY
            )
    )
SELECT
    date_key AS date_key,
    DAYOFYEAR(date_key) AS day_of_year,
    YEARWEEK(date_key) AS week_key,
    WEEKOFYEAR(date_key) AS week_of_year,
    DAYOFWEEK(date_key) AS day_of_week,
    ISODOW(date_key) AS iso_day_of_week,
    DAYNAME(date_key) AS day_name,
    YEAR(date_key) || RIGHT('0' || MONTH(date_key), 2) AS month_key,
    MONTH(date_key) AS month_of_year,
    DAYOFMONTH(date_key) AS day_of_month,
    LEFT(MONTHNAME(date_key), 3) AS month_name_short,
    MONTHNAME(date_key) AS month_name,
    DATE_TRUNC('month', date_key) AS first_day_of_month,
    LAST_DAY(date_key) AS last_day_of_month,
    CAST(YEAR(date_key) || QUARTER(date_key) AS INT) AS quarter_key,
    QUARTER(date_key) AS quarter_of_year,
    ('Q' || QUARTER(date_key)) AS quarter_desc_short,
    ('Quarter ' || QUARTER(date_key)) AS quarter_desc,
    CAST(YEAR(date_key) AS INT) AS year_key,
    ROW_NUMBER() OVER (
        PARTITION BY
            YEAR(date_key),
            MONTH(date_key),
            DAYOFWEEK(date_key)
        ORDER BY
            date_key
    ) AS ordinal_weekday_of_month
FROM
    generate_date