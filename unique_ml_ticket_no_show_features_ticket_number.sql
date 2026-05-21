select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

select
    ticket_number as unique_field,
    count(*) as n_records

from MUSEUM_DW_PROD.ML_FEATURES.ml_ticket_no_show_features
where ticket_number is not null
group by ticket_number
having count(*) > 1



      
    ) dbt_internal_test