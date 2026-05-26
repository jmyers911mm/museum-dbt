{{
    config(
        unique_key='ad_id'
    )
}}

SELECT
    ad_id,
    campaign_id,
    campaign_name,
    adset_name,
    ad_name,
    ad_date,
    platform,
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
    objective,
    placement,
    CASE
        WHEN clicks > 0 THEN spend / clicks
        ELSE NULL
    END AS cost_per_click,
    CASE
        WHEN actions_purchase > 0 THEN spend / actions_purchase
        ELSE NULL
    END AS cost_per_acquisition,
    CASE
        WHEN spend > 0 THEN actions_purchase_value / spend
        ELSE NULL
    END AS roas,
    CASE
        WHEN campaign_name ILIKE '%member%' THEN 'Membership'
        WHEN campaign_name ILIKE '%holiday%' OR campaign_name ILIKE '%promo%' THEN 'Promotions'
        WHEN campaign_name ILIKE '%awareness%' THEN 'Awareness'
        ELSE 'General'
    END AS campaign_category,
    hashdiff,
    _loaded_at
FROM {{ ref('stg_meta_ads') }}
