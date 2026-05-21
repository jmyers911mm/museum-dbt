select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
SELECT unit_price
FROM MUSEUM_DW_PROD.SILVER.silver_pos_tickets
WHERE unit_price < 0
   OR unit_price > 100

      
    ) dbt_internal_test