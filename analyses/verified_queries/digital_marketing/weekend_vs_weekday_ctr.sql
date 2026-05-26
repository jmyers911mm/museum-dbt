-- Verified Query: Weekend vs Weekday CTR
-- Question: How does click-through rate compare between weekends and weekdays?
SELECT
    dd.is_weekend,
    CASE WHEN dd.is_weekend THEN 'Weekend' ELSE 'Weekday' END AS day_type,
    ad.ad_platform,
    ROUND(AVG(ad.ctr) * 100, 2) AS avg_ctr_pct,
    ROUND(AVG(ad.roas), 2) AS avg_roas,
    ROUND(SUM(ad.spend), 2) AS total_spend
FROM {{ ref('fct_digital_ad_performance') }} ad
INNER JOIN {{ ref('dim_date') }} dd ON ad.report_date = dd.date_day
GROUP BY dd.is_weekend, ad.ad_platform
ORDER BY dd.is_weekend, ad.ad_platform
