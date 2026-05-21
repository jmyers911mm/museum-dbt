select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
SELECT event_timestamp
FROM MUSEUM_DW_PROD.SILVER.silver_sf_marketing_cloud
WHERE event_timestamp < DATEADD('hour', -72, CURRENT_TIMESTAMP())
  AND _loaded_at > DATEADD('hour', -24, CURRENT_TIMESTAMP())

      
    ) dbt_internal_test