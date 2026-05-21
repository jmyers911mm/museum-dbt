select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select is_valid_scan
from MUSEUM_DW_PROD.SILVER.silver_ticket_scans
where is_valid_scan is null



      
    ) dbt_internal_test