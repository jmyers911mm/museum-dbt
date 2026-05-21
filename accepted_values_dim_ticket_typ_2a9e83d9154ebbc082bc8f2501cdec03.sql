select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        pricing_tier as value_field,
        count(*) as n_records

    from MUSEUM_DW_PROD.GOLD.dim_ticket_type
    group by pricing_tier

)

select *
from all_values
where value_field not in (
    'Standard','Concession','Membership','Group','Package'
)



      
    ) dbt_internal_test