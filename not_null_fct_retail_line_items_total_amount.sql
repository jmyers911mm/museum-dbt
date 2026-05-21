select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select total_amount
from MUSEUM_DW_PROD.GOLD.fct_retail_line_items
where total_amount is null



      
    ) dbt_internal_test