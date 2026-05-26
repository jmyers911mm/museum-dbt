SELECT
    ad_date AS report_date,
    'Google Ads' AS ad_platform,
    campaign_id,
    campaign_name,
    campaign_category,
    SUM(impressions) AS impressions,
    SUM(clicks) AS clicks,
    SUM(cost) AS spend,
    SUM(conversions) AS conversions,
    SUM(conversion_value) AS conversion_value,
    CASE WHEN SUM(impressions) > 0 THEN SUM(clicks)::FLOAT / SUM(impressions) ELSE 0 END AS ctr,
    CASE WHEN SUM(clicks) > 0 THEN SUM(cost) / SUM(clicks) ELSE NULL END AS avg_cpc,
    CASE WHEN SUM(conversions) > 0 THEN SUM(cost) / SUM(conversions) ELSE NULL END AS cost_per_conversion,
    CASE WHEN SUM(cost) > 0 THEN SUM(conversion_value) / SUM(cost) ELSE NULL END AS roas,
    COUNT(DISTINCT ad_id) AS active_ads,
    COUNT(DISTINCT ad_group_name) AS active_ad_groups,
    CURRENT_TIMESTAMP() AS _loaded_at
FROM {{ ref('silver_google_ads') }}
GROUP BY ad_date, campaign_id, campaign_name, campaign_category

UNION ALL

SELECT
    ad_date AS report_date,
    INITCAP(platform) AS ad_platform,
    campaign_id,
    campaign_name,
    campaign_category,
    SUM(impressions) AS impressions,
    SUM(clicks) AS clicks,
    SUM(spend) AS spend,
    SUM(actions_purchase) AS conversions,
    SUM(actions_purchase_value) AS conversion_value,
    CASE WHEN SUM(impressions) > 0 THEN SUM(clicks)::FLOAT / SUM(impressions) ELSE 0 END AS ctr,
    CASE WHEN SUM(clicks) > 0 THEN SUM(spend) / SUM(clicks) ELSE NULL END AS avg_cpc,
    CASE WHEN SUM(actions_purchase) > 0 THEN SUM(spend) / SUM(actions_purchase) ELSE NULL END AS cost_per_conversion,
    CASE WHEN SUM(spend) > 0 THEN SUM(actions_purchase_value) / SUM(spend) ELSE NULL END AS roas,
    COUNT(DISTINCT ad_id) AS active_ads,
    COUNT(DISTINCT adset_name) AS active_ad_groups,
    CURRENT_TIMESTAMP() AS _loaded_at
FROM {{ ref('silver_meta_ads') }}
GROUP BY ad_date, platform, campaign_id, campaign_name, campaign_category
