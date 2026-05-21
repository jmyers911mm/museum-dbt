
  
    

        create or replace transient table MUSEUM_DW_PROD.ML_FEATURES.ml_donor_upgrade_propensity_features
         as
        (

WITH customer_base AS (
    SELECT
        c.customer_id,
        c.customer_segment,
        c.membership_type,
        c.membership_status,
        c.primary_email,
        c.email_count,
        c.phone_count
    FROM MUSEUM_DW_PROD.GOLD.dim_customer c
    WHERE c.customer_segment = 'Known Member'
),

spending AS (
    SELECT
        customer_id,
        total_ticket_spend,
        total_retail_spend,
        total_lifetime_value,
        total_pos_spend,
        ltv_tier,
        ticket_visits,
        retail_visits,
        total_visits,
        first_transaction_date,
        last_transaction_date,
        customer_tenure_days,
        avg_ticket_spend_per_visit,
        avg_retail_spend_per_visit
    FROM MUSEUM_DW_PROD.GOLD.rpt_customer_ltv
),

email_engagement AS (
    SELECT
        email_address,
        COUNT(DISTINCT CASE WHEN event_type = 'Open' THEN campaign_id END) AS email_opens,
        COUNT(DISTINCT CASE WHEN event_type = 'Click' THEN campaign_id END) AS email_clicks,
        COUNT(DISTINCT CASE WHEN event_type = 'Sent' THEN campaign_id END) AS emails_received,
        DIV0(COUNT(DISTINCT CASE WHEN event_type = 'Open' THEN campaign_id END),
             COUNT(DISTINCT CASE WHEN event_type = 'Sent' THEN campaign_id END)) AS open_rate,
        DIV0(COUNT(DISTINCT CASE WHEN event_type = 'Click' THEN campaign_id END),
             COUNT(DISTINCT CASE WHEN event_type = 'Open' THEN campaign_id END)) AS click_to_open_rate
    FROM MUSEUM_DW_PROD.SILVER.silver_sf_marketing_cloud
    GROUP BY email_address
),

donor_retention AS (
    SELECT
        donor_tier,
        AVG(retention_rate_pct) AS avg_tier_retention
    FROM MUSEUM_DW_PROD.GOLD.fct_donor_retention
    WHERE months_since_acquisition <= 6
    GROUP BY donor_tier
)

SELECT
    cb.customer_id,
    cb.customer_segment,
    cb.membership_type,
    cb.membership_status,
    cb.email_count,
    cb.phone_count,
    COALESCE(s.total_lifetime_value, 0) AS current_ltv,
    COALESCE(s.ltv_tier, 'Bronze') AS current_tier,
    COALESCE(s.total_visits, 0) AS total_visits,
    COALESCE(s.customer_tenure_days, 0) AS tenure_days,
    COALESCE(s.avg_ticket_spend_per_visit, 0) AS avg_ticket_spend,
    COALESCE(s.avg_retail_spend_per_visit, 0) AS avg_retail_spend,
    DIV0(COALESCE(s.total_lifetime_value, 0), NULLIF(s.customer_tenure_days, 0)) * 30 AS monthly_value_velocity,
    COALESCE(ee.open_rate, 0) AS email_open_rate,
    COALESCE(ee.click_to_open_rate, 0) AS email_click_rate,
    COALESCE(ee.emails_received, 0) AS emails_received,
    DATEDIFF('day', s.last_transaction_date, CURRENT_DATE) AS days_since_last_transaction,
    CASE
        WHEN s.ltv_tier = 'Bronze' AND s.total_lifetime_value >= 80 THEN 'Silver'
        WHEN s.ltv_tier = 'Silver' AND s.total_lifetime_value >= 400 THEN 'Gold'
        WHEN s.ltv_tier = 'Gold' AND s.total_lifetime_value >= 800 THEN 'Platinum'
        ELSE NULL
    END AS next_tier_target,
    CASE
        WHEN s.ltv_tier = 'Bronze' THEN 100 - COALESCE(s.total_lifetime_value, 0)
        WHEN s.ltv_tier = 'Silver' THEN 500 - COALESCE(s.total_lifetime_value, 0)
        WHEN s.ltv_tier = 'Gold' THEN 1000 - COALESCE(s.total_lifetime_value, 0)
        ELSE 0
    END AS spend_to_next_tier,
    CASE
        WHEN COALESCE(ee.open_rate, 0) > 0.4
            AND COALESCE(s.total_visits, 0) >= 3
            AND DATEDIFF('day', s.last_transaction_date, CURRENT_DATE) <= 60
            AND DIV0(COALESCE(s.total_lifetime_value, 0), NULLIF(s.customer_tenure_days, 0)) * 30 > 20
        THEN 1
        ELSE 0
    END AS is_upgrade_candidate
FROM customer_base cb
LEFT JOIN spending s ON cb.customer_id = s.customer_id
LEFT JOIN email_engagement ee ON cb.primary_email = ee.email_address
        );
      
  