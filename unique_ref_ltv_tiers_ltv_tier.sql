select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

select
    ltv_tier as unique_field,
    count(*) as n_records

from MUSEUM_DW_PROD.GOLD.ref_ltv_tiers
where ltv_tier is not null
group by ltv_tier
having count(*) > 1



      
    ) dbt_internal_test