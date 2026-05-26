{{
    config(
        materialized='table',
        schema='ML_FEATURES',
        tags=['daily', 'non-critical']
    )
}}

SELECT
    visit_date::TIMESTAMP_NTZ AS ds,
    total_visitors AS y,
    day_of_week,
    CASE WHEN EXTRACT(DOW FROM visit_date) IN (0, 6) THEN 1 ELSE 0 END AS is_weekend,
    EXTRACT(MONTH FROM visit_date) AS month_num,
    ticket_revenue + retail_revenue AS total_revenue,
    ticket_transactions,
    gates_active
FROM {{ ref('fct_daily_operations') }}
WHERE total_visitors > 0
ORDER BY visit_date
