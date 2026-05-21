select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select ticket_type
from MUSEUM_DW_PROD.BRONZE.raw_ticket_capacity
where ticket_type is null



      
    ) dbt_internal_test