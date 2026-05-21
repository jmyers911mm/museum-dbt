select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        event_type as value_field,
        count(*) as n_records

    from MUSEUM_DW_PROD.BRONZE.raw_sf_marketing_cloud
    group by event_type

)

select *
from all_values
where value_field not in (
    'Sent','Open','Click','Bounce','Unsubscribe'
)



      
    ) dbt_internal_test