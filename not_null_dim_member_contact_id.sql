select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select contact_id
from MUSEUM_DW_PROD.GOLD.dim_member
where contact_id is null



      
    ) dbt_internal_test