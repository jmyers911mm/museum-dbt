select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select net_total_revenue
from MUSEUM_DW_PROD.GOLD.rpt_daily_operations
where net_total_revenue is null



      
    ) dbt_internal_test