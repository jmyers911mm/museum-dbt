select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select email
from MUSEUM_DW_PROD.BRONZE.raw_sf_crm
where email is null



      
    ) dbt_internal_test