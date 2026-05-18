WITH member AS (
    SELECT
        m.contact_id,
        m.email,
        m.membership_type,
        m.computed_membership_status,
        m.donor_tier,
        m.donation_total_ytd,
        m.days_since_last_visit,
        m.ticket_purchase_count,
        m.total_ticket_spend,
        m.retail_purchase_count,
        m.total_retail_spend,
        m.total_lifetime_value,
        m.email_opens,
        m.email_clicks,
        m.engagement_segment,
        m.last_interaction_date
    FROM {{ ref('fct_member_360') }} m
    WHERE m.donor_tier != 'Non-Donor'
),

crm AS (
    SELECT
        contact_id,
        preferred_contact_method AS acquisition_method,
        DATE_TRUNC('month', created_date)::DATE AS cohort_month,
        created_date,
        membership_start_date,
        membership_end_date,
        last_donation_date,
        DATEDIFF('month', created_date, CURRENT_DATE()) AS tenure_months,
        DATEDIFF('day', last_donation_date, CURRENT_DATE()) AS days_since_last_donation,
        donation_total_ytd
    FROM {{ ref('silver_sf_crm') }}
    WHERE donation_total_ytd > 0
)

SELECT
    m.contact_id,
    m.membership_type,
    m.computed_membership_status,
    m.donor_tier,
    m.donation_total_ytd,
    m.days_since_last_visit,
    m.total_lifetime_value,
    m.email_opens,
    m.email_clicks,
    CASE WHEN m.email_opens > 0 THEN m.email_clicks::FLOAT / m.email_opens ELSE 0 END AS email_click_through_rate,
    m.engagement_segment,
    c.acquisition_method,
    c.cohort_month,
    c.tenure_months,
    c.days_since_last_donation,
    CASE
        WHEN c.tenure_months > 0
        THEN ROUND(m.donation_total_ytd / c.tenure_months, 2)
        ELSE 0
    END AS donation_velocity_per_month,
    CASE
        WHEN c.days_since_last_donation <= 90 THEN 'Recent'
        WHEN c.days_since_last_donation <= 180 THEN 'Moderate'
        WHEN c.days_since_last_donation <= 365 THEN 'Lapsed'
        ELSE 'Dormant'
    END AS donation_recency_band,
    CASE
        WHEN m.computed_membership_status IN ('Expired', 'Lapsed') THEN 1
        WHEN c.days_since_last_donation > 365 THEN 1
        ELSE 0
    END AS is_churned,
    CASE
        WHEN c.days_since_last_donation > 180 AND m.computed_membership_status = 'Active' THEN 'High'
        WHEN c.days_since_last_donation > 90 AND m.engagement_segment = 'Disengaged' THEN 'High'
        WHEN c.days_since_last_donation > 90 THEN 'Medium'
        ELSE 'Low'
    END AS churn_risk_level,
    CURRENT_TIMESTAMP() AS _feature_computed_at
FROM member m
LEFT JOIN crm c ON m.contact_id = c.contact_id
