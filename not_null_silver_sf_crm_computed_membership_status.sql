select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select computed_membership_status
from MUSEUM_DW_PROD.SILVER.silver_sf_crm
where computed_membership_status is null



      
    ) dbt_internal_test