select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select ltv_tier
from MUSEUM_DW_PROD.GOLD.rpt_customer_ltv
where ltv_tier is null



      
    ) dbt_internal_test