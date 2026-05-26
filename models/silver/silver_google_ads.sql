{{
    config(
        unique_key='ad_id'
    )
}}

SELECT
    ad_id,
    campaign_id,
    campaign_name,
    ad_group_name,
    ad_date,
    impressions,
    clicks,
    cost_micros,
    cost,
    conversions,
    conversion_value,
    click_through_rate,
    cost_per_click,
    CASE
        WHEN conversions > 0 THEN cost / conversions
        ELSE NULL
    END AS cost_per_conversion,
    CASE
        WHEN cost > 0 THEN conversion_value / cost
        ELSE NULL
    END AS roas,
    keyword,
    match_type,
    device,
    network,
    CASE
        WHEN campaign_name ILIKE '%ticket%' OR campaign_name ILIKE '%winter%' THEN 'Tickets'
        WHEN campaign_name ILIKE '%member%' THEN 'Membership'
        WHEN campaign_name ILIKE '%gift%' OR campaign_name ILIKE '%holiday%' OR campaign_name ILIKE '%shop%' THEN 'Retail'
        ELSE 'General'
    END AS campaign_category,
    hashdiff,
    _loaded_at
FROM {{ ref('stg_google_ads') }}
