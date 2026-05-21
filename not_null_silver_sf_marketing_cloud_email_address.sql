select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select email_address
from MUSEUM_DW_PROD.SILVER.silver_sf_marketing_cloud
where email_address is null



      
    ) dbt_internal_test