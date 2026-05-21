select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
SELECT scan_hour
FROM MUSEUM_DW_PROD.SILVER.silver_ticket_scans
WHERE scan_hour < 0
   OR scan_hour > 23

      
    ) dbt_internal_test