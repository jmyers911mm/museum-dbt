select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select is_churned
from MUSEUM_DW_PROD.ML_FEATURES.ml_donor_churn_features
where is_churned is null



      
    ) dbt_internal_test