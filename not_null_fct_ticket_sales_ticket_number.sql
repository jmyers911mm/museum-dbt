select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select ticket_number
from MUSEUM_DW_PROD.GOLD.fct_ticket_sales
where ticket_number is null



      
    ) dbt_internal_test