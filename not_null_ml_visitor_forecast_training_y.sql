select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select y
from MUSEUM_DW_PROD.ML_FEATURES.ml_visitor_forecast_training
where y is null



      
    ) dbt_internal_test