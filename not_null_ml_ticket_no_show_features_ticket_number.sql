select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select ticket_number
from MUSEUM_DW_PROD.ML_FEATURES.ml_ticket_no_show_features
where ticket_number is null



      
    ) dbt_internal_test