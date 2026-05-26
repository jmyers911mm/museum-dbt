{{
    config(
        materialized='table',
        schema='ML_FEATURES',
        tags=['daily', 'non-critical']
    )
}}

WITH campaign_scores AS (
    SELECT
        mc.subscriber_key,
        mc.email_address,
        mc.campaign_id,
        dc.campaign_type,
        dc.audience_size_tier,
        mc.event_type,
        mc.event_timestamp
    FROM {{ ref('silver_sf_marketing_cloud') }} mc
    LEFT JOIN {{ ref('dim_campaign') }} dc ON mc.campaign_id = dc.campaign_id
),

subscriber_engagement AS (
    SELECT
        subscriber_key,
        email_address,
        COUNT(DISTINCT campaign_id) AS campaigns_received,
        COUNT(DISTINCT CASE WHEN event_type = 'Open' THEN campaign_id END) AS campaigns_opened,
        COUNT(DISTINCT CASE WHEN event_type = 'Click' THEN campaign_id END) AS campaigns_clicked,
        DIV0(COUNT(DISTINCT CASE WHEN event_type = 'Open' THEN campaign_id END),
             COUNT(DISTINCT CASE WHEN event_type = 'Sent' THEN campaign_id END)) AS open_rate,
        DIV0(COUNT(DISTINCT CASE WHEN event_type = 'Click' THEN campaign_id END),
             COUNT(DISTINCT CASE WHEN event_type = 'Open' THEN campaign_id END)) AS click_to_open_rate,
        MAX(CASE WHEN event_type = 'Open' THEN event_timestamp END) AS last_open_date,
        DATEDIFF('day', MAX(CASE WHEN event_type = 'Open' THEN event_timestamp END), CURRENT_TIMESTAMP()) AS days_since_last_open
    FROM campaign_scores
    GROUP BY subscriber_key, email_address
),

web_engagement AS (
    SELECT
        source,
        campaign,
        COUNT(*) AS email_driven_sessions,
        SUM(CASE WHEN is_conversion THEN 1 ELSE 0 END) AS email_driven_conversions,
        AVG(session_duration_seconds) AS avg_email_session_duration,
        COUNT(DISTINCT session_date) AS email_visit_days
    FROM {{ ref('silver_google_analytics') }}
    WHERE medium IN ('email', 'newsletter')
    GROUP BY source, campaign
),

paid_engagement AS (
    SELECT
        channel_grouping,
        COUNT(*) AS paid_sessions,
        SUM(CASE WHEN is_conversion THEN 1 ELSE 0 END) AS paid_conversions,
        COUNT(DISTINCT user_pseudo_id) AS paid_unique_users
    FROM {{ ref('silver_google_analytics') }}
    WHERE channel_grouping IN ('Paid Search', 'Paid Social')
    GROUP BY channel_grouping
),

customer_value AS (
    SELECT
        c.primary_email,
        c.customer_id,
        c.customer_segment,
        c.membership_type,
        c.membership_status,
        ltv.total_lifetime_value,
        ltv.ltv_tier,
        ltv.total_visits
    FROM {{ ref('dim_customer') }} c
    LEFT JOIN {{ ref('rpt_customer_ltv') }} ltv ON c.customer_id = ltv.customer_id
)

SELECT
    se.subscriber_key,
    se.email_address,
    se.campaigns_received,
    se.campaigns_opened,
    se.campaigns_clicked,
    se.open_rate,
    se.click_to_open_rate,
    se.days_since_last_open,
    COALESCE(cv.customer_segment, 'Unknown') AS customer_segment,
    COALESCE(cv.membership_type, 'Non-Member') AS membership_type,
    COALESCE(cv.membership_status, 'None') AS membership_status,
    COALESCE(cv.total_lifetime_value, 0) AS lifetime_value,
    COALESCE(cv.ltv_tier, 'None') AS ltv_tier,
    COALESCE(cv.total_visits, 0) AS total_visits,
    COALESCE(we.email_driven_sessions, 0) AS email_driven_web_sessions,
    COALESCE(we.email_driven_conversions, 0) AS email_driven_web_conversions,
    COALESCE(we.avg_email_session_duration, 0) AS avg_email_web_session_duration,
    COALESCE(we.email_visit_days, 0) AS email_web_visit_days,
    COALESCE(pe_search.paid_sessions, 0) AS paid_search_sessions,
    COALESCE(pe_social.paid_sessions, 0) AS paid_social_sessions,
    COALESCE(pe_search.paid_conversions, 0) + COALESCE(pe_social.paid_conversions, 0) AS total_paid_conversions,
    CASE
        WHEN se.click_to_open_rate > 0.3 AND se.open_rate > 0.5 THEN 1
        ELSE 0
    END AS is_high_responder
FROM subscriber_engagement se
LEFT JOIN customer_value cv ON se.email_address = cv.primary_email
LEFT JOIN web_engagement we ON we.source = 'email'
LEFT JOIN paid_engagement pe_search ON pe_search.channel_grouping = 'Paid Search'
LEFT JOIN paid_engagement pe_social ON pe_social.channel_grouping = 'Paid Social'
