select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select days_since_last_visit
from MUSEUM_DW_PROD.SILVER.silver_sf_crm
where days_since_last_visit is null



      
    ) dbt_internal_test