WITH paid_search AS (
    SELECT
        ad_date AS report_date,
        'Paid Search' AS channel,
        SUM(impressions) AS impressions,
        SUM(clicks) AS clicks,
        SUM(cost) AS spend,
        SUM(conversions) AS conversions,
        SUM(conversion_value) AS conversion_value
    FROM {{ ref('silver_google_ads') }}
    WHERE network = 'SEARCH'
    GROUP BY ad_date
),

paid_display AS (
    SELECT
        ad_date AS report_date,
        'Paid Display' AS channel,
        SUM(impressions) AS impressions,
        SUM(clicks) AS clicks,
        SUM(cost) AS spend,
        SUM(conversions) AS conversions,
        SUM(conversion_value) AS conversion_value
    FROM {{ ref('silver_google_ads') }}
    WHERE network = 'DISPLAY'
    GROUP BY ad_date
),

paid_social AS (
    SELECT
        ad_date AS report_date,
        'Paid Social' AS channel,
        SUM(impressions) AS impressions,
        SUM(clicks) AS clicks,
        SUM(spend) AS spend,
        SUM(actions_purchase) AS conversions,
        SUM(actions_purchase_value) AS conversion_value
    FROM {{ ref('silver_meta_ads') }}
    GROUP BY ad_date
),

email AS (
    SELECT
        event_date AS report_date,
        'Email' AS channel,
        COUNT(CASE WHEN event_type = 'Sent' THEN 1 END) AS impressions,
        COUNT(CASE WHEN event_type = 'Click' THEN 1 END) AS clicks,
        0 AS spend,
        0 AS conversions,
        0 AS conversion_value
    FROM {{ ref('silver_sf_marketing_cloud') }}
    GROUP BY event_date
),

organic_search AS (
    SELECT
        report_date,
        'Organic Search' AS channel,
        0 AS impressions,
        SUM(sessions) AS clicks,
        0 AS spend,
        SUM(conversions) AS conversions,
        0 AS conversion_value
    FROM {{ ref('fct_website_traffic') }}
    WHERE channel_grouping = 'Organic Search'
    GROUP BY report_date
),

direct AS (
    SELECT
        report_date,
        'Direct' AS channel,
        0 AS impressions,
        SUM(sessions) AS clicks,
        0 AS spend,
        SUM(conversions) AS conversions,
        0 AS conversion_value
    FROM {{ ref('fct_website_traffic') }}
    WHERE channel_grouping = 'Direct'
    GROUP BY report_date
),

all_channels AS (
    SELECT * FROM paid_search
    UNION ALL SELECT * FROM paid_display
    UNION ALL SELECT * FROM paid_social
    UNION ALL SELECT * FROM email
    UNION ALL SELECT * FROM organic_search
    UNION ALL SELECT * FROM direct
)

SELECT
    ac.report_date,
    dd.fiscal_year,
    dd.month_name,
    dd.is_weekend,
    mc.channel_id,
    ac.channel,
    mc.is_paid,
    mc.cost_model,
    ac.impressions,
    ac.clicks,
    ac.spend,
    ac.conversions,
    ac.conversion_value,
    CASE WHEN ac.impressions > 0 THEN ac.clicks::FLOAT / ac.impressions ELSE NULL END AS ctr,
    CASE WHEN ac.clicks > 0 THEN ac.spend / ac.clicks ELSE NULL END AS cpc,
    CASE WHEN ac.conversions > 0 THEN ac.spend / ac.conversions ELSE NULL END AS cpa,
    CASE WHEN ac.spend > 0 THEN ac.conversion_value / ac.spend ELSE NULL END AS roas,
    CURRENT_TIMESTAMP() AS _loaded_at
FROM all_channels ac
LEFT JOIN {{ ref('dim_date') }} dd ON ac.report_date = dd.date_day
LEFT JOIN {{ ref('dim_marketing_channel') }} mc ON ac.channel = mc.channel_name
