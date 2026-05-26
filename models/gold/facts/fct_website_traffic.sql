SELECT
    session_date AS report_date,
    channel_grouping,
    source,
    medium,
    campaign,
    page_category,
    device_category,
    COUNT(*) AS sessions,
    COUNT(CASE WHEN is_new_user = TRUE THEN 1 END) AS new_user_sessions,
    COUNT(CASE WHEN is_conversion = TRUE THEN 1 END) AS conversions,
    COUNT(DISTINCT user_pseudo_id) AS unique_users,
    SUM(event_count) AS total_events,
    ROUND(AVG(session_duration_seconds), 1) AS avg_session_duration_seconds,
    CASE WHEN COUNT(*) > 0
        THEN ROUND(COUNT(CASE WHEN is_conversion = TRUE THEN 1 END)::FLOAT / COUNT(*) * 100, 2)
        ELSE 0
    END AS conversion_rate_pct,
    CURRENT_TIMESTAMP() AS _loaded_at
FROM {{ ref('silver_google_analytics') }}
GROUP BY
    session_date,
    channel_grouping,
    source,
    medium,
    campaign,
    page_category,
    device_category
