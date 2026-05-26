SELECT visit_date
FROM {{ ref('fct_daily_operations') }}
WHERE total_revenue < 0
