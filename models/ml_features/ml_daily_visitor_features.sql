WITH daily_ops AS (
    SELECT
        visit_date,
        total_visitors AS daily_visitors,
        valid_scans,
        rejected_scans,
        gates_active AS gates_used,
        ticket_transactions AS daily_ticket_txns,
        ticket_revenue AS daily_ticket_revenue,
        CASE WHEN ticket_transactions > 0
            THEN ROUND(ticket_revenue / ticket_transactions, 2)
            ELSE 0
        END AS avg_ticket_value,
        CASE WHEN tickets_sold > 0
            THEN ROUND(ticket_discounts / (ticket_revenue + ticket_discounts), 4)
            ELSE 0
        END AS discount_usage_rate,
        retail_transactions AS daily_retail_txns,
        retail_revenue AS daily_retail_revenue,
        CASE WHEN retail_transactions > 0
            THEN ROUND(retail_revenue / retail_transactions, 2)
            ELSE 0
        END AS avg_basket_value,
        total_revenue AS total_daily_revenue
    FROM {{ ref('fct_daily_operations') }}
),

hourly_traffic AS (
    SELECT
        scan_date,
        MAX(visitors_admitted) AS peak_hour_visitors,
        COUNT(DISTINCT scan_hour) AS active_hours,
        COUNT(DISTINCT gate_id) AS gates_active
    FROM {{ ref('fct_visitor_traffic') }}
    GROUP BY scan_date
),

date_features AS (
    SELECT
        date_day,
        is_weekend,
        day_of_week_num,
        month_num,
        quarter_num
    FROM {{ ref('dim_date') }}
)

SELECT
    d.visit_date AS date_day,
    d.daily_visitors,
    d.valid_scans,
    d.rejected_scans,
    d.gates_used,
    d.daily_ticket_txns,
    d.daily_ticket_revenue,
    d.avg_ticket_value,
    d.discount_usage_rate,
    d.daily_retail_txns,
    d.daily_retail_revenue,
    d.avg_basket_value,
    d.total_daily_revenue,
    h.peak_hour_visitors,
    h.active_hours,
    df.is_weekend,
    df.day_of_week_num,
    df.month_num,
    df.quarter_num,
    AVG(d.daily_visitors) OVER (ORDER BY d.visit_date ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING) AS avg_visitors_7d,
    AVG(d.daily_visitors) OVER (ORDER BY d.visit_date ROWS BETWEEN 30 PRECEDING AND 1 PRECEDING) AS avg_visitors_30d,
    AVG(d.total_daily_revenue) OVER (ORDER BY d.visit_date ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING) AS avg_revenue_7d,
    LAG(d.daily_visitors, 7) OVER (ORDER BY d.visit_date) AS visitors_same_day_last_week,
    CURRENT_TIMESTAMP() AS _feature_computed_at
FROM daily_ops d
LEFT JOIN hourly_traffic h ON d.visit_date = h.scan_date
LEFT JOIN date_features df ON d.visit_date = df.date_day
