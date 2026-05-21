select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

select
    customer_id as unique_field,
    count(*) as n_records

from MUSEUM_DW_PROD.ML_FEATURES.ml_donor_upgrade_propensity_features
where customer_id is not null
group by customer_id
having count(*) > 1



      
    ) dbt_internal_test