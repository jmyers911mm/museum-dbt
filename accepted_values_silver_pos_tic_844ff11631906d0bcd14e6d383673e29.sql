select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        visitor_category as value_field,
        count(*) as n_records

    from MUSEUM_DW_PROD.SILVER.silver_pos_tickets
    group by visitor_category

)

select *
from all_values
where value_field not in (
    'Adult','Child','Senior','Member','School Group','Family','Other'
)



      
    ) dbt_internal_test