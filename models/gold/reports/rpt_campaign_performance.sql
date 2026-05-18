SELECT
    cp.campaign_id,
    cp.campaign_name,
    cp.first_send_date,
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
    cp.unsubscribe_rate_pct
FROM {{ ref('fct_campaign_performance') }} cp
