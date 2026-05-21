select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select payment_method_id
from MUSEUM_DW_PROD.GOLD.dim_payment_method
where payment_method_id is null



      
    ) dbt_internal_test