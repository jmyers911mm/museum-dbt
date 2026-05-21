WITH silver_revenue AS (
    SELECT SUM(total_amount) AS silver_total
    FROM {{ ref('silver_pos_tickets') }}
),
gold_revenue AS (
    SELECT SUM(ticket_revenue) AS gold_total
    FROM {{ ref('fct_daily_operations') }}
)
SELECT
    s.silver_total,
    g.gold_total,
    ABS(s.silver_total - g.gold_total) AS diff
FROM silver_revenue s
CROSS JOIN gold_revenue g
WHERE ABS(s.silver_total - g.gold_total) > 1
