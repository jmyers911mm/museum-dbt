select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

select
    scan_id as unique_field,
    count(*) as n_records

from MUSEUM_DW_PROD.BRONZE.raw_ticket_scans
where scan_id is not null
group by scan_id
having count(*) > 1



      
    ) dbt_internal_test