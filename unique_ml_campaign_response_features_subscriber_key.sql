select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

select
    subscriber_key as unique_field,
    count(*) as n_records

from MUSEUM_DW_PROD.ML_FEATURES.ml_campaign_response_features
where subscriber_key is not null
group by subscriber_key
having count(*) > 1



      
    ) dbt_internal_test