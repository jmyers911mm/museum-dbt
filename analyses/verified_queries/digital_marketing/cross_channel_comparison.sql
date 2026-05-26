-- Verified Query: Cross-Channel Performance Comparison
-- Question: How do all marketing channels compare in terms of spend, conversions, and ROAS?
SELECT
    channel,
    mc.channel_group,
    mc.is_paid,
    ROUND(SUM(cs.spend), 2) AS total_spend,
    SUM(cs.impressions) AS total_impressions,
    SUM(cs.clicks) AS total_clicks,
    SUM(cs.conversions) AS total_conversions,
    ROUND(SUM(cs.conversion_value), 2) AS total_conversion_value,
    ROUND(CASE WHEN SUM(cs.spend) > 0 THEN SUM(cs.conversion_value) / SUM(cs.spend) ELSE NULL END, 2) AS roas
FROM {{ ref('fct_marketing_channel_summary') }} cs
LEFT JOIN {{ ref('dim_marketing_channel') }} mc ON cs.channel = mc.channel_name
GROUP BY channel, mc.channel_group, mc.is_paid
ORDER BY total_spend DESC
