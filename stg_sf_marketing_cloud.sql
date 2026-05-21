
  create or replace   view MUSEUM_DW_PROD.SILVER.stg_sf_marketing_cloud
  
    
    
(
  
    "EVENT_ID" COMMENT $$$$, 
  
    "EVENT_TIMESTAMP" COMMENT $$$$, 
  
    "SUBSCRIBER_KEY" COMMENT $$$$, 
  
    "EMAIL_ADDRESS" COMMENT $$$$, 
  
    "EVENT_TYPE" COMMENT $$$$, 
  
    "CAMPAIGN_ID" COMMENT $$$$, 
  
    "CAMPAIGN_NAME" COMMENT $$$$, 
  
    "SUBJECT_LINE" COMMENT $$$$, 
  
    "LINK_URL" COMMENT $$$$, 
  
    "DEVICE_TYPE" COMMENT $$$$, 
  
    "OPERATING_SYSTEM" COMMENT $$$$, 
  
    "BOUNCE_TYPE" COMMENT $$$$, 
  
    "_LOADED_AT" COMMENT $$$$, 
  
    "HASHDIFF" COMMENT $$$$
  
)

   as (
    SELECT
    event_id,
    event_timestamp,
    subscriber_key,
    LOWER(TRIM(email_address)) AS email_address,
    event_type,
    campaign_id,
    TRIM(campaign_name) AS campaign_name,
    subject_line,
    link_url,
    device_type,
    operating_system,
    bounce_type,
    _loaded_at,
    MD5(CONCAT_WS('||',
        COALESCE(CAST(subscriber_key AS VARCHAR), '^^NULL^^'),
        COALESCE(CAST(email_address AS VARCHAR), '^^NULL^^'),
        COALESCE(CAST(event_type AS VARCHAR), '^^NULL^^'),
        COALESCE(CAST(campaign_id AS VARCHAR), '^^NULL^^'),
        COALESCE(CAST(campaign_name AS VARCHAR), '^^NULL^^'),
        COALESCE(CAST(subject_line AS VARCHAR), '^^NULL^^'),
        COALESCE(CAST(link_url AS VARCHAR), '^^NULL^^'),
        COALESCE(CAST(device_type AS VARCHAR), '^^NULL^^'),
        COALESCE(CAST(operating_system AS VARCHAR), '^^NULL^^'),
        COALESCE(CAST(bounce_type AS VARCHAR), '^^NULL^^')
    )) AS hashdiff
FROM MUSEUM_DW_PROD.BRONZE.raw_sf_marketing_cloud
  );

