select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
SELECT donation_total_ytd
FROM MUSEUM_DW_PROD.SILVER.silver_sf_crm
WHERE donation_total_ytd < 0

      
    ) dbt_internal_test