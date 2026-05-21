select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select campaign_name
from MUSEUM_DW_PROD.GOLD.dim_campaign
where campaign_name is null



      
    ) dbt_internal_test