select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select unit_price
from MUSEUM_DW_PROD.SILVER.silver_pos_tickets
where unit_price is null



      
    ) dbt_internal_test