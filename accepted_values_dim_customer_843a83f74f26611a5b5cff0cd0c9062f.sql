select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        customer_segment as value_field,
        count(*) as n_records

    from MUSEUM_DW_PROD.GOLD.dim_customer
    group by customer_segment

)

select *
from all_values
where value_field not in (
    'Known Member','Identified Visitor','Anonymous'
)



      
    ) dbt_internal_test