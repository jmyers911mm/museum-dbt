select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        membership_type as value_field,
        count(*) as n_records

    from MUSEUM_DW_PROD.SILVER.silver_sf_crm
    group by membership_type

)

select *
from all_values
where value_field not in (
    'Individual','Family','Student','Senior','Patron','Benefactor'
)



      
    ) dbt_internal_test