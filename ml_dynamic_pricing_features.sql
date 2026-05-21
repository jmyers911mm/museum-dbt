
  
    

        create or replace transient table MUSEUM_DW_PROD.ML_FEATURES.ml_dynamic_pricing_features
         as
        (

WITH availability AS (
    SELECT
        entry_date,
        entry_window_start,
        ticket_type,
        ticket_capacity,
        tickets_reserved,
        tickets_available,
        utilization_pct,
        demand_level,
        day_name,
        day_of_week_num,
        is_weekend,
        fiscal_year
    FROM MUSEUM_DW_PROD.GOLD.fct_ticket_availability
),

benchmarks AS (
    SELECT
        ticket_type,
        day_of_week_num,
        entry_window_start,
        avg_reserved,
        median_reserved,
        p90_reserved,
        avg_utilization_pct,
        stddev_reserved,
        lower_bound_2sd,
        upper_bound_2sd
    FROM MUSEUM_DW_PROD.GOLD.fct_ticket_demand_benchmarks
)

SELECT
    a.entry_date,
    a.entry_window_start,
    a.ticket_type,
    a.ticket_capacity,
    a.tickets_reserved,
    a.utilization_pct,
    a.day_of_week_num,
    a.is_weekend,
    EXTRACT(MONTH FROM a.entry_date) AS month_num,
    DATEDIFF('day', CURRENT_DATE, a.entry_date) AS days_until_entry,
    COALESCE(b.avg_reserved, 0) AS benchmark_avg_demand,
    COALESCE(b.p90_reserved, 0) AS benchmark_p90_demand,
    COALESCE(b.avg_utilization_pct, 0) AS benchmark_avg_utilization,
    DIV0(a.tickets_reserved - COALESCE(b.avg_reserved, 0), NULLIF(b.stddev_reserved, 0)) AS demand_z_score,
    CASE
        WHEN a.utilization_pct >= 90 THEN 'surge'
        WHEN a.utilization_pct >= 70 THEN 'high'
        WHEN a.utilization_pct >= 40 THEN 'normal'
        ELSE 'low'
    END AS demand_band,
    a.utilization_pct AS current_price_utilization,
    CASE
        WHEN a.utilization_pct >= 90 THEN 1.25
        WHEN a.utilization_pct >= 70 THEN 1.10
        WHEN a.utilization_pct <= 20 THEN 0.85
        ELSE 1.00
    END AS suggested_price_multiplier
FROM availability a
LEFT JOIN benchmarks b
    ON a.ticket_type = b.ticket_type
    AND a.day_of_week_num = b.day_of_week_num
    AND a.entry_window_start = b.entry_window_start
WHERE a.entry_date >= CURRENT_DATE
        );
      
  