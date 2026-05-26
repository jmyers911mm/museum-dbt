-- Verified Query: ROAS by Platform This Month
-- Question: What is the ROAS for each advertising platform this month?
SELECT
    ad_platform,
    ROUND(SUM(conversion_value), 2) AS total_conversion_value,
    ROUND(SUM(spend), 2) AS total_spend,
    ROUND(CASE WHEN SUM(spend) > 0 THEN SUM(conversion_value) / SUM(spend) ELSE NULL END, 2) AS roas
FROM {{ ref('fct_digital_ad_performance') }}
WHERE report_date >= DATE_TRUNC('month', CURRENT_DATE)
GROUP BY ad_platform
ORDER BY roas DESC
