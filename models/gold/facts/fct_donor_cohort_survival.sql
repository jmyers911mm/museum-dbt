{{
    config(
        materialized='table',
        schema='GOLD',
        cluster_by=['months_since_acquisition'],
        tags=['daily', 'critical']
    )
}}

WITH retention AS (
    SELECT * FROM {{ ref('fct_donor_retention') }}
),

survival_by_cohort AS (
    SELECT
        cohort_month,
        membership_type,
        acquisition_method,
        donor_tier,
        months_since_acquisition,
        COALESCE(MAX(CASE WHEN months_since_acquisition = 0 THEN cohort_size END)
            OVER (PARTITION BY cohort_month, membership_type, acquisition_method, donor_tier), cohort_size) AS original_cohort_size,
        retained_donors,
        retention_rate_pct,
        LAG(retention_rate_pct) OVER (
            PARTITION BY cohort_month, membership_type, acquisition_method, donor_tier
            ORDER BY months_since_acquisition
        ) AS prev_month_retention_pct,
        retention_rate_pct - COALESCE(LAG(retention_rate_pct) OVER (
            PARTITION BY cohort_month, membership_type, acquisition_method, donor_tier
            ORDER BY months_since_acquisition
        ), 100) AS monthly_retention_change_pct
    FROM retention
)

SELECT
    cohort_month,
    membership_type,
    acquisition_method,
    donor_tier,
    months_since_acquisition,
    original_cohort_size,
    retained_donors,
    retention_rate_pct AS survival_rate_pct,
    monthly_retention_change_pct AS monthly_dropoff_pct,
    CASE
        WHEN months_since_acquisition = 0 THEN NULL
        WHEN retention_rate_pct <= 50 AND COALESCE(prev_month_retention_pct, 100) > 50 THEN TRUE
        ELSE FALSE
    END AS is_half_life_month,
    CASE
        WHEN retention_rate_pct > 80 THEN 'Healthy'
        WHEN retention_rate_pct > 50 THEN 'At Risk'
        WHEN retention_rate_pct > 25 THEN 'Declining'
        ELSE 'Critical'
    END AS cohort_health
FROM survival_by_cohort
