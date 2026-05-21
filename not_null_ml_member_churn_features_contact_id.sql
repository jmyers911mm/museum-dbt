select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select contact_id
from MUSEUM_DW_PROD.ML_FEATURES.ml_member_churn_features
where contact_id is null



      
    ) dbt_internal_test