select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        ltv_tier as value_field,
        count(*) as n_records

    from MUSEUM_DW_PROD.GOLD.rpt_customer_ltv
    group by ltv_tier

)

select *
from all_values
where value_field not in (
    'Platinum','Gold','Silver','Bronze'
)



      
    ) dbt_internal_test