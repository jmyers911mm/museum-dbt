select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select event_date
from MUSEUM_DW_PROD.SILVER.silver_sf_marketing_cloud
where event_date is null



      
    ) dbt_internal_test