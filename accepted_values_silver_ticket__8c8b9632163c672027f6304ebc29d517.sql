select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        scan_result as value_field,
        count(*) as n_records

    from MUSEUM_DW_PROD.SILVER.silver_ticket_scans
    group by scan_result

)

select *
from all_values
where value_field not in (
    'VALID','EXPIRED','ALREADY_USED','INVALID'
)



      
    ) dbt_internal_test