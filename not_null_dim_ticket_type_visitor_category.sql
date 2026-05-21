select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select visitor_category
from MUSEUM_DW_PROD.GOLD.dim_ticket_type
where visitor_category is null



      
    ) dbt_internal_test