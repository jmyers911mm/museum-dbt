select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
SELECT membership_duration_days
FROM MUSEUM_DW_PROD.SILVER.silver_sf_crm
WHERE membership_duration_days < 0

      
    ) dbt_internal_test