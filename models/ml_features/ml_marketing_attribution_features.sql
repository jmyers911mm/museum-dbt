WITH sessions_with_conversion AS (
    SELECT
        session_id,
        session_date,
        user_pseudo_id,
        source,
        medium,
        campaign,
        channel_grouping,
        page_category,
        device_category,
        event_name,
        is_conversion,
        session_duration_seconds,
        is_new_user,
        ROW_NUMBER() OVER (PARTITION BY user_pseudo_id ORDER BY session_date, session_id) AS session_sequence,
        COUNT(*) OVER (PARTITION BY user_pseudo_id) AS total_user_sessions,
        SUM(CASE WHEN is_conversion THEN 1 ELSE 0 END) OVER (PARTITION BY user_pseudo_id) AS user_total_conversions
    FROM {{ ref('silver_google_analytics') }}
),

converting_users AS (
    SELECT DISTINCT user_pseudo_id
    FROM sessions_with_conversion
    WHERE is_conversion = TRUE
),

first_touch AS (
    SELECT
        s.user_pseudo_id,
        s.channel_grouping AS first_touch_channel,
        s.source AS first_touch_source,
        s.medium AS first_touch_medium,
        s.campaign AS first_touch_campaign,
        s.session_date AS first_session_date
    FROM sessions_with_conversion s
    WHERE s.session_sequence = 1
      AND s.user_pseudo_id IN (SELECT user_pseudo_id FROM converting_users)
),

last_touch_before_conversion AS (
    SELECT
        s.user_pseudo_id,
        s.channel_grouping AS last_touch_channel,
        s.source AS last_touch_source,
        s.medium AS last_touch_medium,
        s.campaign AS last_touch_campaign,
        s.session_date AS conversion_date,
        s.session_sequence AS conversion_session_number
    FROM sessions_with_conversion s
    WHERE s.is_conversion = TRUE
    QUALIFY ROW_NUMBER() OVER (PARTITION BY s.user_pseudo_id ORDER BY s.session_date DESC) = 1
),

user_path_stats AS (
    SELECT
        s.user_pseudo_id,
        COUNT(DISTINCT s.channel_grouping) AS distinct_channels_used,
        COUNT(DISTINCT s.session_id) AS sessions_before_conversion,
        DATEDIFF('day', MIN(s.session_date), MAX(CASE WHEN s.is_conversion THEN s.session_date END)) AS days_to_convert,
        ARRAY_TO_STRING(ARRAY_AGG(DISTINCT s.channel_grouping), ' > ') AS channel_path,
        SUM(s.session_duration_seconds) AS total_engagement_seconds,
        AVG(s.session_duration_seconds) AS avg_session_duration
    FROM sessions_with_conversion s
    WHERE s.user_pseudo_id IN (SELECT user_pseudo_id FROM converting_users)
    GROUP BY s.user_pseudo_id
)

SELECT
    ft.user_pseudo_id,
    ft.first_touch_channel,
    ft.first_touch_source,
    ft.first_touch_medium,
    ft.first_touch_campaign,
    ft.first_session_date,
    lt.last_touch_channel,
    lt.last_touch_source,
    lt.last_touch_medium,
    lt.last_touch_campaign,
    lt.conversion_date,
    lt.conversion_session_number,
    CASE WHEN ft.first_touch_channel = lt.last_touch_channel THEN TRUE ELSE FALSE END AS is_single_channel_conversion,
    ups.distinct_channels_used,
    ups.sessions_before_conversion,
    ups.days_to_convert,
    ups.channel_path,
    ups.total_engagement_seconds,
    ups.avg_session_duration,
    CASE
        WHEN ups.sessions_before_conversion = 1 THEN 'direct_conversion'
        WHEN ups.sessions_before_conversion <= 3 THEN 'short_path'
        WHEN ups.sessions_before_conversion <= 7 THEN 'medium_path'
        ELSE 'long_path'
    END AS conversion_path_length_tier,
    CURRENT_TIMESTAMP() AS _feature_computed_at
FROM first_touch ft
INNER JOIN last_touch_before_conversion lt ON ft.user_pseudo_id = lt.user_pseudo_id
INNER JOIN user_path_stats ups ON ft.user_pseudo_id = ups.user_pseudo_id
