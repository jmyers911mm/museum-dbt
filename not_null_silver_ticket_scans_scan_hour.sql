select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select scan_hour
from MUSEUM_DW_PROD.SILVER.silver_ticket_scans
where scan_hour is null



      
    ) dbt_internal_test