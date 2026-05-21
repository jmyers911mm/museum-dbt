
  
    

        create or replace transient table MUSEUM_DW_PROD.SILVER.silver_sf_marketing_cloud
        copy grants as
        (SELECT
    event_id,
    event_timestamp,
    DATE_TRUNC('day', event_timestamp) AS event_date,
    subscriber_key,
    email_address,
    event_type,
    campaign_id,
    campaign_name,
    subject_line,
    link_url,
    device_type,
    operating_system,
    bounce_type,
    CASE WHEN bounce_type IS NOT NULL THEN TRUE ELSE FALSE END AS is_bounced,
    CASE WHEN event_type = 'Unsubscribe' THEN TRUE ELSE FALSE END AS is_unsubscribed,
    hashdiff,
    _loaded_at
FROM MUSEUM_DW_PROD.SILVER.stg_sf_marketing_cloud
        );
      
  