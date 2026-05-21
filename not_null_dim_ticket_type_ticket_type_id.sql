select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select ticket_type_id
from MUSEUM_DW_PROD.GOLD.dim_ticket_type
where ticket_type_id is null



      
    ) dbt_internal_test