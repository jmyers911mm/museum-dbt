select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select quantity
from MUSEUM_DW_PROD.BRONZE.raw_pos_tickets
where quantity is null



      
    ) dbt_internal_test