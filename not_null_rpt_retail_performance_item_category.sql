select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select item_category
from MUSEUM_DW_PROD.GOLD.rpt_retail_performance
where item_category is null



      
    ) dbt_internal_test