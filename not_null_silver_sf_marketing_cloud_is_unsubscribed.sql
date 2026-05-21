select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select is_unsubscribed
from MUSEUM_DW_PROD.SILVER.silver_sf_marketing_cloud
where is_unsubscribed is null



      
    ) dbt_internal_test