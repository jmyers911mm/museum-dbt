select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select scan_date
from MUSEUM_DW_PROD.GOLD.rpt_visitor_traffic
where scan_date is null



      
    ) dbt_internal_test