SELECT
    cp.campaign_id,
    dc.campaign_name,
    dc.campaign_type,
    dc.audience_size_tier,
    dc.campaign_duration_days,
    cp.first_send_date,
    dd.fiscal_year,
    dd.month_name,
    dd.is_weekend AS sent_on_weekend,
    cp.last_event_date,
    cp.total_sent,
    cp.total_opens,
    cp.total_clicks,
    cp.total_bounces,
    cp.total_unsubscribes,
    cp.unique_recipients,
    cp.open_rate_pct,
    cp.click_to_open_rate_pct,
    cp.bounce_rate_pct,
    cp.unsubscribe_rate_pct,
    DATEDIFF('day', cp.first_send_date, cp.last_event_date) AS engagement_window_days
FROM {{ ref('fct_campaign_performance') }} cp
LEFT JOIN {{ ref('dim_campaign') }} dc ON cp.campaign_id = dc.campaign_id
LEFT JOIN {{ ref('dim_date') }} dd ON cp.first_send_date::DATE = dd.date_day
