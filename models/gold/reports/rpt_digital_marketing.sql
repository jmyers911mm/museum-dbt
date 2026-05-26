SELECT
    dd.date_day AS report_date,
    dd.fiscal_year,
    dd.month_name,
    dd.is_weekend,
    ads.ad_platform,
    ads.campaign_name,
    ads.campaign_category,
    ads.impressions AS ad_impressions,
    ads.clicks AS ad_clicks,
    ads.spend AS ad_spend,
    ads.conversions AS ad_conversions,
    ads.conversion_value AS ad_conversion_value,
    ads.roas AS ad_roas,
    ads.ctr AS ad_ctr,
    ads.avg_cpc,
    ads.cost_per_conversion,
    wt.sessions,
    wt.new_user_sessions,
    wt.conversions AS website_conversions,
    wt.unique_users,
    wt.avg_session_duration_seconds,
    wt.conversion_rate_pct AS website_conversion_rate_pct,
    CASE WHEN ads.spend > 0 THEN wt.sessions / ads.spend ELSE NULL END AS sessions_per_dollar,
    CASE WHEN ads.spend > 0 THEN wt.conversions / ads.spend ELSE NULL END AS website_conversions_per_dollar
FROM {{ ref('fct_digital_ad_performance') }} ads
LEFT JOIN {{ ref('fct_website_traffic') }} wt
    ON ads.report_date = wt.report_date
    AND ads.campaign_category = wt.page_category
LEFT JOIN {{ ref('dim_date') }} dd
    ON ads.report_date = dd.date_day
