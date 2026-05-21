select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        payment_method as value_field,
        count(*) as n_records

    from MUSEUM_DW_PROD.BRONZE.raw_pos_tickets
    group by payment_method

)

select *
from all_values
where value_field not in (
    'Credit Card','Debit Card','Cash','Mobile Pay'
)



      
    ) dbt_internal_test