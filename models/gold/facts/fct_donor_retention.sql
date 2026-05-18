WITH donors AS (
    SELECT
        contact_id,
        email,
        membership_type,
        computed_membership_status,
        donor_tier,
        donation_total_ytd,
        preferred_contact_method AS acquisition_method,
        DATE_TRUNC('month', created_date)::DATE AS cohort_month,
        created_date,
        membership_start_date,
        membership_end_date,
        last_donation_date,
        last_visit_date
    FROM {{ ref('silver_sf_crm') }}
    WHERE donation_total_ytd > 0
),

months AS (
    SELECT date_day AS month_start
    FROM {{ ref('dim_date') }}
    WHERE day_of_month = 1
),

donor_months AS (
    SELECT
        d.contact_id,
        d.cohort_month,
        d.membership_type,
        d.acquisition_method,
        d.donor_tier,
        m.month_start AS observation_month,
        DATEDIFF('month', d.cohort_month, m.month_start) AS months_since_acquisition,
        d.membership_end_date,
        d.last_donation_date,
        d.last_visit_date,
        d.donation_total_ytd
    FROM donors d
    CROSS JOIN months m
    WHERE m.month_start >= d.cohort_month
      AND m.month_start <= CURRENT_DATE()
)

SELECT
    cohort_month,
    months_since_acquisition,
    observation_month,
    COUNT(DISTINCT contact_id) AS cohort_size,
    COUNT(DISTINCT CASE
        WHEN last_donation_date >= observation_month
         OR last_visit_date >= observation_month
         OR (membership_end_date IS NULL OR membership_end_date >= observation_month)
        THEN contact_id
    END) AS retained_donors,
    ROUND(COUNT(DISTINCT CASE
        WHEN last_donation_date >= observation_month
         OR last_visit_date >= observation_month
         OR (membership_end_date IS NULL OR membership_end_date >= observation_month)
        THEN contact_id
    END)::FLOAT / NULLIF(COUNT(DISTINCT contact_id), 0) * 100, 2) AS retention_rate_pct,
    100 - ROUND(COUNT(DISTINCT CASE
        WHEN last_donation_date >= observation_month
         OR last_visit_date >= observation_month
         OR (membership_end_date IS NULL OR membership_end_date >= observation_month)
        THEN contact_id
    END)::FLOAT / NULLIF(COUNT(DISTINCT contact_id), 0) * 100, 2) AS churn_rate_pct
FROM donor_months
GROUP BY cohort_month, months_since_acquisition, observation_month
