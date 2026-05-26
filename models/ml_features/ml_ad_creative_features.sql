WITH google_ads_creative AS (
    SELECT
        ad_id,
        ad_date,
        campaign_id,
        campaign_name,
        ad_group_name,
        campaign_category,
        'Google Ads' AS ad_platform,
        network AS placement,
        device,
        keyword,
        match_type,
        NULL AS ad_name,
        NULL AS objective,
        impressions,
        clicks,
        cost AS spend,
        conversions,
        conversion_value,
        CASE WHEN impressions > 0 THEN clicks::FLOAT / impressions ELSE 0 END AS ctr,
        CASE WHEN clicks > 0 THEN cost / clicks ELSE NULL END AS cpc,
        CASE WHEN conversions > 0 THEN cost / conversions ELSE NULL END AS cpa,
        CASE WHEN cost > 0 THEN conversion_value / cost ELSE NULL END AS roas
    FROM {{ ref('silver_google_ads') }}
),

meta_ads_creative AS (
    SELECT
        ad_id,
        ad_date,
        campaign_id,
        campaign_name,
        adset_name AS ad_group_name,
        campaign_category,
        INITCAP(platform) AS ad_platform,
        placement,
        NULL AS device,
        NULL AS keyword,
        NULL AS match_type,
        ad_name,
        objective,
        impressions,
        clicks,
        spend,
        actions_purchase AS conversions,
        actions_purchase_value AS conversion_value,
        ctr,
        cost_per_click AS cpc,
        cost_per_acquisition AS cpa,
        roas
    FROM {{ ref('silver_meta_ads') }}
),

combined AS (
    SELECT * FROM google_ads_creative
    UNION ALL
    SELECT * FROM meta_ads_creative
),

creative_rolling AS (
    SELECT
        *,
        AVG(ctr) OVER (PARTITION BY ad_platform, placement ORDER BY ad_date ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING) AS avg_ctr_7d,
        AVG(roas) OVER (PARTITION BY ad_platform, placement ORDER BY ad_date ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING) AS avg_roas_7d,
        AVG(cpc) OVER (PARTITION BY ad_platform, placement ORDER BY ad_date ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING) AS avg_cpc_7d,
        SUM(spend) OVER (PARTITION BY ad_platform, campaign_id, ad_group_name ORDER BY ad_date) AS cumulative_spend,
        SUM(conversions) OVER (PARTITION BY ad_platform, campaign_id, ad_group_name ORDER BY ad_date) AS cumulative_conversions
    FROM combined
)

SELECT
    ad_id,
    ad_date,
    ad_platform,
    campaign_id,
    campaign_name,
    ad_group_name,
    campaign_category,
    placement,
    device,
    keyword,
    match_type,
    ad_name,
    objective,
    impressions,
    clicks,
    spend,
    conversions,
    conversion_value,
    ctr,
    cpc,
    cpa,
    roas,
    avg_ctr_7d,
    avg_roas_7d,
    avg_cpc_7d,
    cumulative_spend,
    cumulative_conversions,
    CASE WHEN cumulative_spend > 0 THEN cumulative_conversions / cumulative_spend ELSE NULL END AS cumulative_efficiency,
    CASE WHEN avg_ctr_7d > 0 THEN (ctr - avg_ctr_7d) / avg_ctr_7d ELSE NULL END AS ctr_vs_avg_pct,
    CASE WHEN avg_roas_7d > 0 THEN (roas - avg_roas_7d) / avg_roas_7d ELSE NULL END AS roas_vs_avg_pct,
    CASE
        WHEN roas >= 3.0 AND ctr > COALESCE(avg_ctr_7d, 0) THEN 'top_performer'
        WHEN roas >= 1.5 THEN 'good_performer'
        WHEN roas >= 0.5 THEN 'underperformer'
        ELSE 'poor_performer'
    END AS creative_performance_tier,
    CURRENT_TIMESTAMP() AS _feature_computed_at
FROM creative_rolling
