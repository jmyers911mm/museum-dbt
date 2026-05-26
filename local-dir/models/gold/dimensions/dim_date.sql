{{
    config(
        materialized='table',
        contract={"enforced": true},
        columns=[
            {"name": "date_day", "data_type": "DATE"},
            {"name": "year_num", "data_type": "NUMBER"},
            {"name": "quarter_num", "data_type": "NUMBER"},
            {"name": "month_num", "data_type": "NUMBER"},
            {"name": "month_name", "data_type": "VARCHAR"},
            {"name": "week_of_year", "data_type": "NUMBER"},
            {"name": "day_of_week_num", "data_type": "NUMBER"},
            {"name": "day_name", "data_type": "VARCHAR"},
            {"name": "day_of_month", "data_type": "NUMBER"},
            {"name": "day_of_year", "data_type": "NUMBER"},
            {"name": "is_weekend", "data_type": "BOOLEAN"},
            {"name": "fiscal_year", "data_type": "VARCHAR"},
            {"name": "fiscal_quarter", "data_type": "NUMBER"},
            {"name": "is_today", "data_type": "BOOLEAN"},
            {"name": "days_ago", "data_type": "NUMBER"}
        ]
    )
}}

WITH date_spine AS (
    SELECT
        DATEADD('day', seq4(), '2025-01-01'::DATE) AS date_day
    FROM TABLE(GENERATOR(ROWCOUNT => 1096))
)
SELECT
    date_day,
    YEAR(date_day) AS year_num,
    QUARTER(date_day) AS quarter_num,
    MONTH(date_day) AS month_num,
    MONTHNAME(date_day) AS month_name,
    WEEKOFYEAR(date_day) AS week_of_year,
    DAYOFWEEKISO(date_day) AS day_of_week_num,
    DAYNAME(date_day) AS day_name,
    DAY(date_day) AS day_of_month,
    DAYOFYEAR(date_day) AS day_of_year,
    CASE WHEN DAYOFWEEKISO(date_day) IN (6, 7) THEN TRUE ELSE FALSE END AS is_weekend,
    CASE
        WHEN MONTH(date_day) >= 7 THEN 'FY' || (YEAR(date_day) + 1)::VARCHAR
        ELSE 'FY' || YEAR(date_day)::VARCHAR
    END AS fiscal_year,
    CASE
        WHEN MONTH(date_day) IN (7, 8, 9) THEN 1
        WHEN MONTH(date_day) IN (10, 11, 12) THEN 2
        WHEN MONTH(date_day) IN (1, 2, 3) THEN 3
        ELSE 4
    END AS fiscal_quarter,
    CASE WHEN date_day = CURRENT_DATE() THEN TRUE ELSE FALSE END AS is_today,
    DATEDIFF('day', date_day, CURRENT_DATE()) AS days_ago
FROM date_spine
