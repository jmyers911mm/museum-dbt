select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
SELECT days_since_last_visit
FROM MUSEUM_DW_PROD.SILVER.silver_sf_crm
WHERE days_since_last_visit < 0
   OR days_since_last_visit > 3650

      
    ) dbt_internal_test