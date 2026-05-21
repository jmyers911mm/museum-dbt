select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
SELECT quantity
FROM MUSEUM_DW_PROD.SILVER.silver_pos_tickets
WHERE quantity < 1
   OR quantity > 50

      
    ) dbt_internal_test