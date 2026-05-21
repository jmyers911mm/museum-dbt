select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select campaign_id
from MUSEUM_DW_PROD.BRONZE.raw_sf_marketing_cloud
where campaign_id is null



      
    ) dbt_internal_test