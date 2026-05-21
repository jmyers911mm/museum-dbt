
  
    

        create or replace transient table MUSEUM_DW_PROD.GOLD.fct_campaign_performance
        copy grants as
        (SELECT
    campaign_id,
    campaign_name,
    MIN(event_date) AS first_send_date,
    MAX(event_date) AS last_event_date,
    COUNT(CASE WHEN event_type = 'Sent' THEN 1 END) AS total_sent,
    COUNT(CASE WHEN event_type = 'Open' THEN 1 END) AS total_opens,
    COUNT(CASE WHEN event_type = 'Click' THEN 1 END) AS total_clicks,
    COUNT(CASE WHEN event_type = 'Bounce' THEN 1 END) AS total_bounces,
    COUNT(CASE WHEN event_type = 'Unsubscribe' THEN 1 END) AS total_unsubscribes,
    COUNT(DISTINCT subscriber_key) AS unique_recipients,
    ROUND(CASE WHEN COUNT(CASE WHEN event_type = 'Sent' THEN 1 END) > 0
        THEN COUNT(CASE WHEN event_type = 'Open' THEN 1 END)::FLOAT / COUNT(CASE WHEN event_type = 'Sent' THEN 1 END) * 100
        ELSE 0 END, 2) AS open_rate_pct,
    ROUND(CASE WHEN COUNT(CASE WHEN event_type = 'Open' THEN 1 END) > 0
        THEN COUNT(CASE WHEN event_type = 'Click' THEN 1 END)::FLOAT / COUNT(CASE WHEN event_type = 'Open' THEN 1 END) * 100
        ELSE 0 END, 2) AS click_to_open_rate_pct,
    ROUND(CASE WHEN COUNT(CASE WHEN event_type = 'Sent' THEN 1 END) > 0
        THEN COUNT(CASE WHEN event_type = 'Bounce' THEN 1 END)::FLOAT / COUNT(CASE WHEN event_type = 'Sent' THEN 1 END) * 100
        ELSE 0 END, 2) AS bounce_rate_pct,
    ROUND(CASE WHEN COUNT(CASE WHEN event_type = 'Sent' THEN 1 END) > 0
        THEN COUNT(CASE WHEN event_type = 'Unsubscribe' THEN 1 END)::FLOAT / COUNT(CASE WHEN event_type = 'Sent' THEN 1 END) * 100
        ELSE 0 END, 2) AS unsubscribe_rate_pct,
    CURRENT_TIMESTAMP() AS _loaded_at
FROM MUSEUM_DW_PROD.SILVER.silver_sf_marketing_cloud
GROUP BY campaign_id, campaign_name
        );
      
  