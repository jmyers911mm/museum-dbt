select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select quantity
from MUSEUM_DW_PROD.GOLD.fct_retail_line_items
where quantity is null



      
    ) dbt_internal_test