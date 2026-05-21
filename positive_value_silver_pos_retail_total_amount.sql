select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
SELECT total_amount
FROM MUSEUM_DW_PROD.SILVER.silver_pos_retail
WHERE total_amount < 0

      
    ) dbt_internal_test