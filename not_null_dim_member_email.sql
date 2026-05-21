select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select email
from MUSEUM_DW_PROD.GOLD.dim_member
where email is null



      
    ) dbt_internal_test