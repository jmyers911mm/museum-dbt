select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select customer_segment
from MUSEUM_DW_PROD.GOLD.dim_customer
where customer_segment is null



      
    ) dbt_internal_test