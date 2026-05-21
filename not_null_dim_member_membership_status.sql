select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select membership_status
from MUSEUM_DW_PROD.GOLD.dim_member
where membership_status is null



      
    ) dbt_internal_test