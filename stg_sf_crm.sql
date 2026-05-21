
  create or replace   view MUSEUM_DW_PROD.SILVER.stg_sf_crm
  
    
    
(
  
    "CONTACT_ID" COMMENT $$$$, 
  
    "FIRST_NAME" COMMENT $$$$, 
  
    "LAST_NAME" COMMENT $$$$, 
  
    "EMAIL" COMMENT $$$$, 
  
    "PHONE" COMMENT $$$$, 
  
    "MEMBERSHIP_TYPE" COMMENT $$$$, 
  
    "MEMBERSHIP_STATUS" COMMENT $$$$, 
  
    "MEMBERSHIP_START_DATE" COMMENT $$$$, 
  
    "MEMBERSHIP_END_DATE" COMMENT $$$$, 
  
    "DONATION_TOTAL_YTD" COMMENT $$$$, 
  
    "LAST_DONATION_DATE" COMMENT $$$$, 
  
    "LAST_VISIT_DATE" COMMENT $$$$, 
  
    "PREFERRED_CONTACT_METHOD" COMMENT $$$$, 
  
    "OPT_IN_EMAIL" COMMENT $$$$, 
  
    "CREATED_DATE" COMMENT $$$$, 
  
    "LAST_MODIFIED_DATE" COMMENT $$$$, 
  
    "_LOADED_AT" COMMENT $$$$, 
  
    "HASHDIFF" COMMENT $$$$
  
)

   as (
    SELECT
    contact_id,
    TRIM(first_name) AS first_name,
    TRIM(last_name) AS last_name,
    LOWER(TRIM(email)) AS email,
    phone,
    membership_type,
    membership_status,
    membership_start_date,
    membership_end_date,
    donation_total_ytd,
    last_donation_date,
    last_visit_date,
    preferred_contact_method,
    opt_in_email,
    created_date,
    last_modified_date,
    _loaded_at,
    MD5(CONCAT_WS('||',
        COALESCE(CAST(first_name AS VARCHAR), '^^NULL^^'),
        COALESCE(CAST(last_name AS VARCHAR), '^^NULL^^'),
        COALESCE(CAST(email AS VARCHAR), '^^NULL^^'),
        COALESCE(CAST(phone AS VARCHAR), '^^NULL^^'),
        COALESCE(CAST(membership_type AS VARCHAR), '^^NULL^^'),
        COALESCE(CAST(membership_status AS VARCHAR), '^^NULL^^'),
        COALESCE(CAST(membership_start_date AS VARCHAR), '^^NULL^^'),
        COALESCE(CAST(membership_end_date AS VARCHAR), '^^NULL^^'),
        COALESCE(CAST(donation_total_ytd AS VARCHAR), '^^NULL^^'),
        COALESCE(CAST(last_donation_date AS VARCHAR), '^^NULL^^'),
        COALESCE(CAST(last_visit_date AS VARCHAR), '^^NULL^^'),
        COALESCE(CAST(preferred_contact_method AS VARCHAR), '^^NULL^^'),
        COALESCE(CAST(opt_in_email AS VARCHAR), '^^NULL^^')
    )) AS hashdiff
FROM MUSEUM_DW_PROD.BRONZE.raw_sf_crm
  );

