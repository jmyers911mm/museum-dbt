select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select gate_name
from MUSEUM_DW_PROD.GOLD.dim_gate
where gate_name is null



      
    ) dbt_internal_test