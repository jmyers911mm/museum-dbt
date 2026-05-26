-- Verified Query: Website Conversion Funnel
-- Question: What is the website conversion funnel by channel?
SELECT
    channel_grouping,
    SUM(total_visitors) AS total_visitors,
    SUM(stage_tickets_viewed) AS viewed_tickets,
    SUM(stage_converted) AS converted,
    ROUND(CASE WHEN SUM(total_visitors) > 0 THEN SUM(stage_tickets_viewed)::FLOAT / SUM(total_visitors) * 100 ELSE 0 END, 2) AS tickets_view_rate_pct,
    ROUND(CASE WHEN SUM(total_visitors) > 0 THEN SUM(stage_converted)::FLOAT / SUM(total_visitors) * 100 ELSE 0 END, 2) AS conversion_rate_pct
FROM {{ ref('fct_website_funnel') }}
GROUP BY channel_grouping
ORDER BY total_visitors DESC
