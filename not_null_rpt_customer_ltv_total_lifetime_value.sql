select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select total_lifetime_value
from MUSEUM_DW_PROD.GOLD.rpt_customer_ltv
where total_lifetime_value is null



      
    ) dbt_internal_test