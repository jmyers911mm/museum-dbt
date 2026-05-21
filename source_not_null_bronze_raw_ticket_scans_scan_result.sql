select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select scan_result
from MUSEUM_DW_PROD.BRONZE.raw_ticket_scans
where scan_result is null



      
    ) dbt_internal_test