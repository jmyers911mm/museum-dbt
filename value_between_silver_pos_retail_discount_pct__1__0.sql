select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
SELECT discount_pct
FROM MUSEUM_DW_PROD.SILVER.silver_pos_retail
WHERE discount_pct < 0
   OR discount_pct > 1

      
    ) dbt_internal_test