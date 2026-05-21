select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select ticket_type
from MUSEUM_DW_PROD.SILVER.silver_pos_tickets
where ticket_type is null



      
    ) dbt_internal_test