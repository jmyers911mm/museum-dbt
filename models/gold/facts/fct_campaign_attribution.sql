{{
    config(
        materialized='table',
        cluster_by=['report_date', 'channel_grouping']
    )
}}

WITH campaign_spend AS (
    SELECT
        report_date,
        ad_platform,
        campaign_id,
        campaign_name,
        campaign_category,
        SUM(impressions) AS impressions,
        SUM(clicks) AS clicks,
        SUM(spend) AS spend,
        SUM(conversions) AS ad_conversions,
        SUM(conversion_value) AS ad_conversion_value
    FROM {{ ref('fct_ad_campaign_daily') }}
    GROUP BY report_date, ad_platform, campaign_id, campaign_name, campaign_category
),

attributed_sessions AS (
    SELECT
        session_date,
        channel_grouping,
        source,
        medium,
        customer_id,
        customer_segment,
        membership_type
    FROM {{ ref('bridge_session_customer') }}
    WHERE matched_to_customer = TRUE
),

attributed_ticket_revenue AS (
    SELECT
        ts.transaction_date,
        bsc.channel_grouping,
        bsc.source,
        bsc.medium,
        bsc.customer_segment,
        bsc.membership_type,
        COUNT(DISTINCT ts.transaction_id) AS attributed_ticket_transactions,
        SUM(ts.quantity) AS attributed_tickets_sold,
        SUM(ts.total_amount) AS attributed_ticket_revenue
    FROM {{ ref('fct_ticket_sales') }} ts
    INNER JOIN attributed_sessions bsc
        ON ts.customer_id = bsc.customer_id
        AND ts.transaction_date = bsc.session_date
    GROUP BY ts.transaction_date, bsc.channel_grouping, bsc.source, bsc.medium, bsc.customer_segment, bsc.membership_type
),

attributed_retail_revenue AS (
    SELECT
        r.transaction_date,
        bsc.channel_grouping,
        bsc.source,
        bsc.medium,
        bsc.customer_segment,
        bsc.membership_type,
        COUNT(DISTINCT r.transaction_id) AS attributed_retail_transactions,
        SUM(r.quantity) AS attributed_retail_items,
        SUM(r.total_amount) AS attributed_retail_revenue
    FROM {{ ref('fct_retail_line_items') }} r
    INNER JOIN attributed_sessions bsc
        ON r.customer_id = bsc.customer_id
        AND r.transaction_date = bsc.session_date
    GROUP BY r.transaction_date, bsc.channel_grouping, bsc.source, bsc.medium, bsc.customer_segment, bsc.membership_type
)

SELECT
    COALESCE(t.transaction_date, r.transaction_date) AS report_date,
    dd.fiscal_year,
    dd.month_name,
    dd.is_weekend,
    COALESCE(t.channel_grouping, r.channel_grouping) AS channel_grouping,
    COALESCE(t.source, r.source) AS source,
    COALESCE(t.medium, r.medium) AS medium,
    COALESCE(t.customer_segment, r.customer_segment) AS customer_segment,
    COALESCE(t.membership_type, r.membership_type) AS membership_type,
    COALESCE(t.attributed_ticket_transactions, 0) AS attributed_ticket_transactions,
    COALESCE(t.attributed_tickets_sold, 0) AS attributed_tickets_sold,
    COALESCE(t.attributed_ticket_revenue, 0) AS attributed_ticket_revenue,
    COALESCE(r.attributed_retail_transactions, 0) AS attributed_retail_transactions,
    COALESCE(r.attributed_retail_items, 0) AS attributed_retail_items,
    COALESCE(r.attributed_retail_revenue, 0) AS attributed_retail_revenue,
    COALESCE(t.attributed_ticket_revenue, 0) + COALESCE(r.attributed_retail_revenue, 0) AS total_attributed_revenue,
    CURRENT_TIMESTAMP() AS _loaded_at
FROM attributed_ticket_revenue t
FULL OUTER JOIN attributed_retail_revenue r
    ON t.transaction_date = r.transaction_date
    AND t.channel_grouping = r.channel_grouping
    AND t.source = r.source
    AND t.medium = r.medium
    AND t.customer_segment = r.customer_segment
    AND t.membership_type = r.membership_type
LEFT JOIN {{ ref('dim_date') }} dd
    ON COALESCE(t.transaction_date, r.transaction_date) = dd.date_day
