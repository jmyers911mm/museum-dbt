select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select entry_window_start
from MUSEUM_DW_PROD.BRONZE.raw_ticket_capacity
where entry_window_start is null



      
    ) dbt_internal_test