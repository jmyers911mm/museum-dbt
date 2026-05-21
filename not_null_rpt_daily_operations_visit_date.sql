select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select visit_date
from MUSEUM_DW_PROD.GOLD.rpt_daily_operations
where visit_date is null



      
    ) dbt_internal_test