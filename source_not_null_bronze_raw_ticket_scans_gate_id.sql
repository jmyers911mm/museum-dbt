select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select gate_id
from MUSEUM_DW_PROD.BRONZE.raw_ticket_scans
where gate_id is null



      
    ) dbt_internal_test