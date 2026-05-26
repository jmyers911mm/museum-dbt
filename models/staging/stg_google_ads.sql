{{
    config(
        tags=['daily', 'critical']
    )
}}

SELECT
    ad_id,
    campaign_id,
    TRIM(campaign_name) AS campaign_name,
    TRIM(ad_group_name) AS ad_group_name,
    ad_date::DATE AS ad_date,
    impressions,
    clicks,
    cost_micros,
    cost_micros / 1000000.0 AS cost,
    conversions,
    conversion_value,
    click_through_rate,
    cost_per_click,
    LOWER(TRIM(keyword)) AS keyword,
    UPPER(TRIM(match_type)) AS match_type,
    UPPER(TRIM(device)) AS device,
    UPPER(TRIM(network)) AS network,
    CURRENT_TIMESTAMP() AS _loaded_at,
    {{ generate_hashdiff([
        'campaign_id', 'campaign_name', 'ad_group_name', 'impressions',
        'clicks', 'cost_micros', 'conversions', 'conversion_value',
        'keyword', 'match_type', 'device', 'network'
    ]) }} AS hashdiff
FROM {{ source('bronze', 'raw_google_ads') }}
