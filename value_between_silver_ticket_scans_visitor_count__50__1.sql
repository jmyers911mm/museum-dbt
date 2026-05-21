select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
SELECT visitor_count
FROM MUSEUM_DW_PROD.SILVER.silver_ticket_scans
WHERE visitor_count < 1
   OR visitor_count > 50

      
    ) dbt_internal_test