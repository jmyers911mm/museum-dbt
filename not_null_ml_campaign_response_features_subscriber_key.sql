select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select subscriber_key
from MUSEUM_DW_PROD.ML_FEATURES.ml_campaign_response_features
where subscriber_key is null



      
    ) dbt_internal_test