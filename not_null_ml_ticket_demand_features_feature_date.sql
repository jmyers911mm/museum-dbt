select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select feature_date
from MUSEUM_DW_PROD.ML_FEATURES.ml_ticket_demand_features
where feature_date is null



      
    ) dbt_internal_test