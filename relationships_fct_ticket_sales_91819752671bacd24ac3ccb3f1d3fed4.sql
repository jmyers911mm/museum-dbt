select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with child as (
    select entry_gate as from_field
    from MUSEUM_DW_PROD.GOLD.fct_ticket_sales
    where entry_gate is not null
),

parent as (
    select gate_id as to_field
    from MUSEUM_DW_PROD.GOLD.dim_gate
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null



      
    ) dbt_internal_test