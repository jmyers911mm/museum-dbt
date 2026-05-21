select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select transaction_date
from MUSEUM_DW_PROD.SILVER.silver_pos_retail
where transaction_date is null



      
    ) dbt_internal_test