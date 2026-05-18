{{
    config(
        materialized='table',
        schema='GOLD',
        tags=['daily', 'critical']
    )
}}

WITH historical AS (
    SELECT
        ticket_type,
        day_name,
        day_of_week_num,
        is_weekend,
        entry_window_start,
        tickets_reserved,
        ticket_capacity,
        utilization_pct
    FROM {{ ref('fct_ticket_availability') }}
    WHERE entry_date >= DATEADD('day', -90, CURRENT_DATE())
      AND entry_date < CURRENT_DATE()
)

SELECT
    ticket_type,
    day_name,
    day_of_week_num,
    is_weekend,
    entry_window_start,
    COUNT(*) AS sample_days,
    ROUND(AVG(tickets_reserved), 1) AS avg_reserved,
    ROUND(MEDIAN(tickets_reserved), 1) AS median_reserved,
    MIN(tickets_reserved) AS min_reserved,
    MAX(tickets_reserved) AS max_reserved,
    ROUND(STDDEV(tickets_reserved), 2) AS stddev_reserved,
    ROUND(PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY tickets_reserved), 1) AS p25_reserved,
    ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY tickets_reserved), 1) AS p75_reserved,
    ROUND(PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY tickets_reserved), 1) AS p90_reserved,
    ROUND(AVG(ticket_capacity), 0) AS avg_capacity,
    ROUND(AVG(utilization_pct), 2) AS avg_utilization_pct,
    ROUND(PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY utilization_pct), 2) AS p90_utilization_pct,
    CASE
        WHEN AVG(utilization_pct) >= 80 THEN 'Consistently High'
        WHEN AVG(utilization_pct) >= 50 THEN 'Moderate'
        WHEN AVG(utilization_pct) >= 20 THEN 'Low'
        ELSE 'Very Low'
    END AS typical_demand_level,
    ROUND(AVG(tickets_reserved) - 2 * STDDEV(tickets_reserved), 1) AS lower_bound_2sd,
    ROUND(AVG(tickets_reserved) + 2 * STDDEV(tickets_reserved), 1) AS upper_bound_2sd
FROM historical
GROUP BY 1, 2, 3, 4, 5
