
  
    

        create or replace transient table MUSEUM_DW_PROD.ML_FEATURES.ml_email_send_time_features
         as
        (

WITH campaign_sends AS (
    SELECT
        subscriber_key,
        email_address,
        campaign_id,
        event_timestamp AS send_timestamp,
        EXTRACT(HOUR FROM event_timestamp) AS send_hour,
        EXTRACT(DOW FROM event_timestamp) AS send_dow
    FROM MUSEUM_DW_PROD.SILVER.silver_sf_marketing_cloud
    WHERE event_type = 'Sent'
),

campaign_opens AS (
    SELECT
        subscriber_key,
        campaign_id,
        MIN(event_timestamp) AS first_open_timestamp,
        EXTRACT(HOUR FROM MIN(event_timestamp)) AS open_hour
    FROM MUSEUM_DW_PROD.SILVER.silver_sf_marketing_cloud
    WHERE event_type = 'Open'
    GROUP BY subscriber_key, campaign_id
),

subscriber_history AS (
    SELECT
        subscriber_key,
        COUNT(DISTINCT campaign_id) AS total_sends_received,
        COUNT(DISTINCT CASE WHEN event_type = 'Open' THEN campaign_id END) AS total_opens,
        DIV0(COUNT(DISTINCT CASE WHEN event_type = 'Open' THEN campaign_id END),
             COUNT(DISTINCT CASE WHEN event_type = 'Sent' THEN campaign_id END)) AS historical_open_rate,
        MODE(EXTRACT(HOUR FROM CASE WHEN event_type = 'Open' THEN event_timestamp END)) AS preferred_open_hour
    FROM MUSEUM_DW_PROD.SILVER.silver_sf_marketing_cloud
    GROUP BY subscriber_key
)

SELECT
    s.subscriber_key,
    s.email_address,
    s.campaign_id,
    s.send_timestamp,
    s.send_hour,
    s.send_dow,
    CASE WHEN o.first_open_timestamp IS NOT NULL THEN 1 ELSE 0 END AS was_opened,
    o.open_hour,
    DATEDIFF('minute', s.send_timestamp, o.first_open_timestamp) AS minutes_to_open,
    sh.total_sends_received,
    sh.total_opens,
    sh.historical_open_rate,
    sh.preferred_open_hour,
    ABS(s.send_hour - COALESCE(sh.preferred_open_hour, 10)) AS hours_from_preferred,
    CASE
        WHEN s.send_hour BETWEEN 6 AND 9 THEN 'early_morning'
        WHEN s.send_hour BETWEEN 10 AND 12 THEN 'late_morning'
        WHEN s.send_hour BETWEEN 13 AND 16 THEN 'afternoon'
        WHEN s.send_hour BETWEEN 17 AND 20 THEN 'evening'
        ELSE 'off_hours'
    END AS send_time_bucket
FROM campaign_sends s
LEFT JOIN campaign_opens o ON s.subscriber_key = o.subscriber_key AND s.campaign_id = o.campaign_id
LEFT JOIN subscriber_history sh ON s.subscriber_key = sh.subscriber_key
        );
      
  