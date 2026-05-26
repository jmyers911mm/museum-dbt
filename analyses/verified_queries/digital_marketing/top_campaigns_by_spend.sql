-- Verified Query: Top Campaigns by Spend
-- Question: What are the top 10 campaigns by total spend?
SELECT
    ad_platform,
    campaign_name,
    campaign_category,
    ROUND(SUM(spend), 2) AS total_spend,
    SUM(impressions) AS total_impressions,
    SUM(clicks) AS total_clicks,
    SUM(conversions) AS total_conversions,
    ROUND(CASE WHEN SUM(spend) > 0 THEN SUM(conversion_value) / SUM(spend) ELSE NULL END, 2) AS roas
FROM {{ ref('fct_digital_ad_performance') }}
GROUP BY ad_platform, campaign_name, campaign_category
ORDER BY total_spend DESC
LIMIT 10
