WITH ops_dates AS (
    SELECT COUNT(DISTINCT visit_date) AS ops_days
    FROM {{ ref('fct_daily_operations') }}
),
expected AS (
    SELECT COUNT(DISTINCT scan_date) AS scan_days
    FROM {{ ref('silver_ticket_scans') }}
)
SELECT ops_days, scan_days
FROM ops_dates
CROSS JOIN expected
WHERE ops_days < scan_days
