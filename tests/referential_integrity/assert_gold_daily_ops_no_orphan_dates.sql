WITH daily_ops_dates AS (
    SELECT DISTINCT visit_date
    FROM {{ ref('fct_daily_operations') }}
),
silver_ticket_dates AS (
    SELECT DISTINCT transaction_date AS visit_date
    FROM {{ ref('silver_pos_tickets') }}
),
silver_scan_dates AS (
    SELECT DISTINCT scan_date AS visit_date
    FROM {{ ref('silver_ticket_scans') }}
),
all_silver_dates AS (
    SELECT visit_date FROM silver_ticket_dates
    UNION
    SELECT visit_date FROM silver_scan_dates
)
SELECT g.visit_date
FROM daily_ops_dates g
LEFT JOIN all_silver_dates s ON g.visit_date = s.visit_date
WHERE s.visit_date IS NULL
