select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select item_sku
from MUSEUM_DW_PROD.BRONZE.raw_pos_retail
where item_sku is null



      
    ) dbt_internal_test