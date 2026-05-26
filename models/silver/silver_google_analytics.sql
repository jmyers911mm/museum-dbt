{{
    config(
        unique_key='session_id'
    )
}}

SELECT
    session_id,
    session_date,
    user_pseudo_id,
    source,
    medium,
    campaign,
    CASE
        WHEN medium = 'cpc' THEN 'Paid Search'
        WHEN medium = 'paid' THEN 'Paid Social'
        WHEN medium = 'organic' THEN 'Organic Search'
        WHEN medium = 'email' OR medium = 'newsletter' THEN 'Email'
        WHEN source = '(direct)' THEN 'Direct'
        ELSE 'Other'
    END AS channel_grouping,
    page_path,
    CASE
        WHEN page_path LIKE '%ticket%' THEN 'Tickets'
        WHEN page_path LIKE '%member%' THEN 'Membership'
        WHEN page_path LIKE '%gift%' OR page_path LIKE '%shop%' THEN 'Retail'
        WHEN page_path LIKE '%exhib%' THEN 'Exhibitions'
        WHEN page_path LIKE '%donat%' THEN 'Donations'
        ELSE 'General'
    END AS page_category,
    event_name,
    CASE WHEN event_name = 'purchase' THEN TRUE ELSE FALSE END AS is_conversion,
    event_count,
    session_duration_seconds,
    is_new_user,
    device_category,
    city,
    country,
    hashdiff,
    _loaded_at
FROM {{ ref('stg_google_analytics') }}
