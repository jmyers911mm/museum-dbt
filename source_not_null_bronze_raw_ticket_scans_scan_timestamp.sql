select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select scan_timestamp
from MUSEUM_DW_PROD.BRONZE.raw_ticket_scans
where scan_timestamp is null



      
    ) dbt_internal_test