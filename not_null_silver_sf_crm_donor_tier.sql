select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select donor_tier
from MUSEUM_DW_PROD.SILVER.silver_sf_crm
where donor_tier is null



      
    ) dbt_internal_test