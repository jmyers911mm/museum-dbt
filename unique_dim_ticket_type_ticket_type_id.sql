select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

select
    ticket_type_id as unique_field,
    count(*) as n_records

from MUSEUM_DW_PROD.GOLD.dim_ticket_type
where ticket_type_id is not null
group by ticket_type_id
having count(*) > 1



      
    ) dbt_internal_test