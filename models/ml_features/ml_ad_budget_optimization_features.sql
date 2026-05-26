WITH platform_daily AS (
    SELECT
        report_date,
        ad_platform,
        campaign_category,
        SUM(impressions) AS impressions,
        SUM(clicks) AS clicks,
        SUM(spend) AS spend,
        SUM(conversions) AS conversions,
        SUM(conversion_value) AS conversion_value,
        CASE WHEN SUM(impressions) > 0 THEN SUM(clicks)::FLOAT / SUM(impressions) ELSE 0 END AS ctr,
        CASE WHEN SUM(clicks) > 0 THEN SUM(spend) / SUM(clicks) ELSE NULL END AS cpc,
        CASE WHEN SUM(conversions) > 0 THEN SUM(spend) / SUM(conversions) ELSE NULL END AS cpa,
        CASE WHEN SUM(spend) > 0 THEN SUM(conversion_value) / SUM(spend) ELSE NULL END AS roas
    FROM {{ ref('fct_digital_ad_performance') }}
    GROUP BY report_date, ad_platform, campaign_category
),

platform_rolling AS (
    SELECT
        *,
        AVG(spend) OVER (PARTITION BY ad_platform, campaign_category ORDER BY report_date ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING) AS avg_spend_7d,
        AVG(roas) OVER (PARTITION BY ad_platform, campaign_category ORDER BY report_date ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING) AS avg_roas_7d,
        AVG(cpa) OVER (PARTITION BY ad_platform, campaign_category ORDER BY report_date ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING) AS avg_cpa_7d,
        AVG(conversions) OVER (PARTITION BY ad_platform, campaign_category ORDER BY report_date ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING) AS avg_conversions_7d,
        SUM(spend) OVER (PARTITION BY ad_platform, campaign_category ORDER BY report_date ROWS BETWEEN 30 PRECEDING AND 1 PRECEDING) AS cumulative_spend_30d,
        SUM(conversion_value) OVER (PARTITION BY ad_platform, campaign_category ORDER BY report_date ROWS BETWEEN 30 PRECEDING AND 1 PRECEDING) AS cumulative_revenue_30d,
        LAG(roas, 1) OVER (PARTITION BY ad_platform, campaign_category ORDER BY report_date) AS roas_prior_day,
        LAG(roas, 7) OVER (PARTITION BY ad_platform, campaign_category ORDER BY report_date) AS roas_7d_ago
    FROM platform_daily
),

platform_totals AS (
    SELECT
        report_date,
        SUM(spend) AS total_daily_spend,
        SUM(conversion_value) AS total_daily_revenue
    FROM platform_daily
    GROUP BY report_date
)

SELECT
    pr.report_date,
    pr.ad_platform,
    pr.campaign_category,
    pr.impressions,
    pr.clicks,
    pr.spend,
    pr.conversions,
    pr.conversion_value,
    pr.ctr,
    pr.cpc,
    pr.cpa,
    pr.roas,
    pr.avg_spend_7d,
    pr.avg_roas_7d,
    pr.avg_cpa_7d,
    pr.avg_conversions_7d,
    pr.cumulative_spend_30d,
    pr.cumulative_revenue_30d,
    CASE WHEN pr.cumulative_spend_30d > 0 THEN pr.cumulative_revenue_30d / pr.cumulative_spend_30d ELSE NULL END AS roas_30d,
    pr.roas_prior_day,
    pr.roas_7d_ago,
    CASE WHEN pr.roas_prior_day > 0 THEN (pr.roas - pr.roas_prior_day) / pr.roas_prior_day ELSE NULL END AS roas_change_pct,
    CASE WHEN pt.total_daily_spend > 0 THEN pr.spend / pt.total_daily_spend ELSE 0 END AS spend_share_pct,
    CASE WHEN pt.total_daily_revenue > 0 THEN pr.conversion_value / pt.total_daily_revenue ELSE 0 END AS revenue_share_pct,
    CASE
        WHEN pr.roas >= 3.0 THEN 'high_performer'
        WHEN pr.roas >= 1.0 THEN 'moderate_performer'
        WHEN pr.roas > 0 THEN 'low_performer'
        ELSE 'no_conversions'
    END AS performance_tier,
    CASE
        WHEN pr.avg_roas_7d IS NOT NULL AND pr.roas > pr.avg_roas_7d * 1.2 THEN 'increase_budget'
        WHEN pr.avg_roas_7d IS NOT NULL AND pr.roas < pr.avg_roas_7d * 0.5 THEN 'decrease_budget'
        ELSE 'maintain'
    END AS budget_recommendation,
    CURRENT_TIMESTAMP() AS _feature_computed_at
FROM platform_rolling pr
LEFT JOIN platform_totals pt ON pr.report_date = pt.report_date
