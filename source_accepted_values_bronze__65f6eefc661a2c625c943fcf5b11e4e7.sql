select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        membership_status as value_field,
        count(*) as n_records

    from MUSEUM_DW_PROD.BRONZE.raw_sf_crm
    group by membership_status

)

select *
from all_values
where value_field not in (
    'Active','Expired','Lapsed'
)



      
    ) dbt_internal_test