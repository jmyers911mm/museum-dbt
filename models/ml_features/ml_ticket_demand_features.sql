{{
    config(
        materialized='table',
        schema='ML_FEATURES',
        transient=true,
        tags=['daily', 'non-critical']
    )
}}

WITH daily_demand AS (
    SELECT
        entry_date,
        ticket_type,
        SUM(tickets_reserved) AS daily_reserved,
        SUM(ticket_capacity) AS daily_capacity,
        ROUND(SUM(tickets_reserved)::FLOAT / NULLIF(SUM(ticket_capacity), 0) * 100, 2) AS daily_utilization_pct,
        COUNT(CASE WHEN demand_level = 'Sold Out' THEN 1 END) AS windows_sold_out,
        COUNT(CASE WHEN demand_level IN ('Sold Out', 'High Demand') THEN 1 END) AS windows_high_demand,
        COUNT(*) AS total_windows
    FROM {{ ref('fct_ticket_availability') }}
    GROUP BY 1, 2
),

with_features AS (
    SELECT
        d.*,
        dd.day_of_week_num,
        dd.day_name,
        dd.is_weekend,
        dd.month_num,
        dd.fiscal_year,
        LAG(d.daily_reserved, 1) OVER (PARTITION BY d.ticket_type ORDER BY d.entry_date) AS reserved_lag_1d,
        LAG(d.daily_reserved, 7) OVER (PARTITION BY d.ticket_type ORDER BY d.entry_date) AS reserved_lag_7d,
        AVG(d.daily_reserved) OVER (PARTITION BY d.ticket_type ORDER BY d.entry_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS reserved_7d_avg,
        AVG(d.daily_reserved) OVER (PARTITION BY d.ticket_type ORDER BY d.entry_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS reserved_30d_avg,
        STDDEV(d.daily_reserved) OVER (PARTITION BY d.ticket_type ORDER BY d.entry_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS reserved_30d_stddev
    FROM daily_demand d
    LEFT JOIN {{ ref('dim_date') }} dd ON d.entry_date = dd.date_day
)

SELECT
    entry_date,
    ticket_type,
    daily_reserved,
    daily_capacity,
    daily_utilization_pct,
    windows_sold_out,
    windows_high_demand,
    total_windows,
    day_of_week_num,
    day_name,
    is_weekend,
    month_num,
    fiscal_year,
    reserved_lag_1d,
    reserved_lag_7d,
    reserved_7d_avg,
    reserved_30d_avg,
    reserved_30d_stddev,
    CASE
        WHEN reserved_30d_stddev > 0
        THEN ROUND((daily_reserved - reserved_30d_avg) / reserved_30d_stddev, 2)
        ELSE 0
    END AS demand_z_score,
    CURRENT_TIMESTAMP() AS _feature_computed_at
FROM with_features
