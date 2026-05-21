select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

select
    feature_date as unique_field,
    count(*) as n_records

from MUSEUM_DW_PROD.ML_FEATURES.ml_daily_visitor_features
where feature_date is not null
group by feature_date
having count(*) > 1



      
    ) dbt_internal_test