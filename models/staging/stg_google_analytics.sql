{{
    config(
        tags=['daily', 'critical']
    )
}}

SELECT
    session_id,
    session_date::DATE AS session_date,
    user_pseudo_id,
    LOWER(TRIM(source)) AS source,
    LOWER(TRIM(medium)) AS medium,
    TRIM(campaign) AS campaign,
    LOWER(TRIM(page_path)) AS page_path,
    LOWER(TRIM(event_name)) AS event_name,
    event_count,
    session_duration_seconds,
    is_new_user,
    LOWER(TRIM(device_category)) AS device_category,
    TRIM(city) AS city,
    TRIM(country) AS country,
    CURRENT_TIMESTAMP() AS _loaded_at,
    {{ generate_hashdiff([
        'user_pseudo_id', 'source', 'medium', 'campaign', 'page_path',
        'event_name', 'event_count', 'session_duration_seconds',
        'is_new_user', 'device_category', 'city'
    ]) }} AS hashdiff
FROM {{ source('bronze', 'raw_google_analytics') }}
