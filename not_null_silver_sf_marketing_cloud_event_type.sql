select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select event_type
from MUSEUM_DW_PROD.SILVER.silver_sf_marketing_cloud
where event_type is null



      
    ) dbt_internal_test