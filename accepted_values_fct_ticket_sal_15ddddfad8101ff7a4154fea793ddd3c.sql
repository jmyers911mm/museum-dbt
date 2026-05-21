select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        utilization_status as value_field,
        count(*) as n_records

    from MUSEUM_DW_PROD.GOLD.fct_ticket_sales
    group by utilization_status

)

select *
from all_values
where value_field not in (
    'Used','Unused','Rejected'
)



      
    ) dbt_internal_test