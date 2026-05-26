{{
    config(
        tags=['daily', 'critical']
    )
}}

SELECT
    ad_id,
    campaign_id,
    TRIM(campaign_name) AS campaign_name,
    TRIM(adset_name) AS adset_name,
    TRIM(ad_name) AS ad_name,
    ad_date::DATE AS ad_date,
    LOWER(TRIM(platform)) AS platform,
    impressions,
    reach,
    clicks,
    spend,
    actions_link_click,
    actions_purchase,
    actions_purchase_value,
    cpm,
    ctr,
    frequency,
    UPPER(TRIM(objective)) AS objective,
    LOWER(TRIM(placement)) AS placement,
    CURRENT_TIMESTAMP() AS _loaded_at,
    {{ generate_hashdiff([
        'campaign_id', 'campaign_name', 'adset_name', 'ad_name',
        'platform', 'impressions', 'reach', 'clicks', 'spend',
        'actions_link_click', 'actions_purchase', 'actions_purchase_value',
        'objective', 'placement'
    ]) }} AS hashdiff
FROM {{ source('bronze', 'raw_meta_ads') }}
