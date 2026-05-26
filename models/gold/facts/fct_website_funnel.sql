WITH session_pages AS (
    SELECT
        session_date,
        user_pseudo_id,
        channel_grouping,
        device_category,
        page_category,
        is_conversion,
        session_duration_seconds
    FROM {{ ref('silver_google_analytics') }}
),

funnel_stages AS (
    SELECT
        session_date,
        channel_grouping,
        device_category,
        COUNT(DISTINCT user_pseudo_id) AS total_visitors,
        COUNT(DISTINCT CASE WHEN page_category = 'General' THEN user_pseudo_id END) AS stage_landing,
        COUNT(DISTINCT CASE WHEN page_category = 'Tickets' THEN user_pseudo_id END) AS stage_tickets_viewed,
        COUNT(DISTINCT CASE WHEN page_category = 'Membership' THEN user_pseudo_id END) AS stage_membership_viewed,
        COUNT(DISTINCT CASE WHEN page_category = 'Retail' THEN user_pseudo_id END) AS stage_retail_viewed,
        COUNT(DISTINCT CASE WHEN page_category = 'Exhibitions' THEN user_pseudo_id END) AS stage_exhibitions_viewed,
        COUNT(DISTINCT CASE WHEN page_category = 'Donations' THEN user_pseudo_id END) AS stage_donations_viewed,
        COUNT(DISTINCT CASE WHEN is_conversion THEN user_pseudo_id END) AS stage_converted,
        AVG(session_duration_seconds) AS avg_session_duration
    FROM session_pages
    GROUP BY session_date, channel_grouping, device_category
)

SELECT
    session_date AS report_date,
    channel_grouping,
    device_category,
    total_visitors,
    stage_landing,
    stage_tickets_viewed,
    stage_membership_viewed,
    stage_retail_viewed,
    stage_exhibitions_viewed,
    stage_donations_viewed,
    stage_converted,
    CASE WHEN total_visitors > 0 THEN ROUND(stage_tickets_viewed::FLOAT / total_visitors * 100, 2) ELSE 0 END AS tickets_view_rate_pct,
    CASE WHEN stage_tickets_viewed > 0 THEN ROUND(stage_converted::FLOAT / stage_tickets_viewed * 100, 2) ELSE 0 END AS tickets_to_conversion_rate_pct,
    CASE WHEN total_visitors > 0 THEN ROUND(stage_converted::FLOAT / total_visitors * 100, 2) ELSE 0 END AS overall_conversion_rate_pct,
    CASE WHEN total_visitors > 0 THEN ROUND((total_visitors - stage_converted)::FLOAT / total_visitors * 100, 2) ELSE 0 END AS overall_drop_off_rate_pct,
    avg_session_duration,
    CURRENT_TIMESTAMP() AS _loaded_at
FROM funnel_stages
