select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select total_amount
from MUSEUM_DW_PROD.GOLD.fct_ticket_sales
where total_amount is null



      
    ) dbt_internal_test