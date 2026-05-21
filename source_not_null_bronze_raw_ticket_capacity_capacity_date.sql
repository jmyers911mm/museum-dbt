select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select capacity_date
from MUSEUM_DW_PROD.BRONZE.raw_ticket_capacity
where capacity_date is null



      
    ) dbt_internal_test