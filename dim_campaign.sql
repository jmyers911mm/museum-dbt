
  
    

        create or replace transient table MUSEUM_DW_PROD.GOLD.dim_campaign
        copy grants as
        (SELECT
    campaign_id,
    campaign_name,
    first_send_date,
    last_event_date,
    DATEDIFF('day', first_send_date, last_event_date) AS campaign_duration_days,
    unique_recipients,
    CASE
        WHEN campaign_name ILIKE '%member%' THEN 'Membership'
        WHEN campaign_name ILIKE '%donation%' OR campaign_name ILIKE '%appeal%' THEN 'Fundraising'
        WHEN campaign_name ILIKE '%newsletter%' THEN 'Newsletter'
        WHEN campaign_name ILIKE '%sale%' OR campaign_name ILIKE '%shop%' THEN 'Retail Promotion'
        WHEN campaign_name ILIKE '%exhibition%' OR campaign_name ILIKE '%promo%' THEN 'Exhibition Promotion'
        ELSE 'General'
    END AS campaign_type,
    CASE
        WHEN unique_recipients >= 200 THEN 'Large'
        WHEN unique_recipients >= 100 THEN 'Medium'
        ELSE 'Small'
    END AS audience_size_tier
FROM MUSEUM_DW_PROD.GOLD.fct_campaign_performance
        );
      
  