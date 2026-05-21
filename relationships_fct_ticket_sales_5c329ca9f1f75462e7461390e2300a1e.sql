select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with child as (
    select ticket_type as from_field
    from MUSEUM_DW_PROD.GOLD.fct_ticket_sales
    where ticket_type is not null
),

parent as (
    select ticket_type_id as to_field
    from MUSEUM_DW_PROD.GOLD.dim_ticket_type
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null



      
    ) dbt_internal_test