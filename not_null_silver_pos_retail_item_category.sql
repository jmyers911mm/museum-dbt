select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select item_category
from MUSEUM_DW_PROD.SILVER.silver_pos_retail
where item_category is null



      
    ) dbt_internal_test