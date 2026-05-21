select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select fiscal_year
from MUSEUM_DW_PROD.GOLD.dim_date
where fiscal_year is null



      
    ) dbt_internal_test