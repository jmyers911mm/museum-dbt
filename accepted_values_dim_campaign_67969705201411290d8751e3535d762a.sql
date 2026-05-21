select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        campaign_type as value_field,
        count(*) as n_records

    from MUSEUM_DW_PROD.GOLD.dim_campaign
    group by campaign_type

)

select *
from all_values
where value_field not in (
    'Membership','Fundraising','Newsletter','Retail Promotion','Exhibition Promotion','General'
)



      
    ) dbt_internal_test