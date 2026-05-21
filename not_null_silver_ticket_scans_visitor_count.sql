select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select visitor_count
from MUSEUM_DW_PROD.SILVER.silver_ticket_scans
where visitor_count is null



      
    ) dbt_internal_test