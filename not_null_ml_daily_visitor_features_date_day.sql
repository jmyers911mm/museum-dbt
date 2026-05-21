select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select date_day
from MUSEUM_DW_PROD.ML_FEATURES.ml_daily_visitor_features
where date_day is null



      
    ) dbt_internal_test