select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        donor_tier as value_field,
        count(*) as n_records

    from MUSEUM_DW_PROD.SILVER.silver_sf_crm
    group by donor_tier

)

select *
from all_values
where value_field not in (
    'Major Donor','Mid-Level Donor','Donor','Small Donor','Non-Donor'
)



      
    ) dbt_internal_test