select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        computed_membership_status as value_field,
        count(*) as n_records

    from MUSEUM_DW_PROD.SILVER.silver_sf_crm
    group by computed_membership_status

)

select *
from all_values
where value_field not in (
    'Active','Grace Period','Expired','Lapsed','Unknown'
)



      
    ) dbt_internal_test