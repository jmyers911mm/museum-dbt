{{
    config(
        materialized='table',
        cluster_by=['report_date']
    )
}}

WITH marketing AS (
    SELECT
        report_date,
        channel,
        is_paid,
        SUM(impressions) AS impressions,
        SUM(clicks) AS clicks,
        SUM(spend) AS spend,
        SUM(conversions) AS conversions,
        SUM(conversion_value) AS conversion_value
    FROM {{ ref('fct_marketing_channel_summary') }}
    GROUP BY report_date, channel, is_paid
),

ticket_sales AS (
    SELECT
        transaction_date AS report_date,
        COUNT(DISTINCT transaction_id) AS ticket_transactions,
        SUM(quantity) AS tickets_sold,
        SUM(total_amount) AS ticket_revenue,
        SUM(discount_amount) AS ticket_discounts
    FROM {{ ref('fct_ticket_sales') }}
    GROUP BY transaction_date
),

retail_sales AS (
    SELECT
        transaction_date AS report_date,
        COUNT(DISTINCT transaction_id) AS retail_transactions,
        SUM(quantity) AS retail_items_sold,
        SUM(total_amount) AS retail_revenue,
        SUM(discount_amount) AS retail_discounts
    FROM {{ ref('fct_retail_line_items') }}
    GROUP BY transaction_date
)

SELECT
    m.report_date,
    dd.fiscal_year,
    dd.month_name,
    dd.day_name,
    dd.is_weekend,
    m.channel,
    m.is_paid,
    m.impressions,
    m.clicks,
    m.spend,
    m.conversions,
    m.conversion_value,
    COALESCE(ts.ticket_transactions, 0) AS ticket_transactions,
    COALESCE(ts.tickets_sold, 0) AS tickets_sold,
    COALESCE(ts.ticket_revenue, 0) AS ticket_revenue,
    COALESCE(ts.ticket_discounts, 0) AS ticket_discounts,
    COALESCE(rs.retail_transactions, 0) AS retail_transactions,
    COALESCE(rs.retail_items_sold, 0) AS retail_items_sold,
    COALESCE(rs.retail_revenue, 0) AS retail_revenue,
    COALESCE(rs.retail_discounts, 0) AS retail_discounts,
    COALESCE(ts.ticket_revenue, 0) + COALESCE(rs.retail_revenue, 0) AS total_sales_revenue,
    CASE WHEN m.spend > 0
        THEN (COALESCE(ts.ticket_revenue, 0) + COALESCE(rs.retail_revenue, 0)) / m.spend
        ELSE NULL
    END AS revenue_to_spend_ratio,
    CURRENT_TIMESTAMP() AS _loaded_at
FROM marketing m
LEFT JOIN ticket_sales ts ON m.report_date = ts.report_date
LEFT JOIN retail_sales rs ON m.report_date = rs.report_date
LEFT JOIN {{ ref('dim_date') }} dd ON m.report_date = dd.date_day
