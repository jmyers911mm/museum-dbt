WITH silver_visitors AS (
    SELECT SUM(CASE WHEN is_valid_scan THEN visitor_count ELSE 0 END) AS silver_total
    FROM {{ ref('silver_ticket_scans') }}
),
gold_visitors AS (
    SELECT SUM(total_visitors) AS gold_total
    FROM {{ ref('fct_daily_operations') }}
)
SELECT
    s.silver_total,
    g.gold_total,
    ABS(s.silver_total - g.gold_total) AS diff
FROM silver_visitors s
CROSS JOIN gold_visitors g
WHERE ABS(s.silver_total - g.gold_total) > 0
