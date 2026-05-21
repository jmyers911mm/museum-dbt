select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        payment_category as value_field,
        count(*) as n_records

    from MUSEUM_DW_PROD.GOLD.dim_payment_method
    group by payment_category

)

select *
from all_values
where value_field not in (
    'Card','Cash','Digital','Other'
)



      
    ) dbt_internal_test