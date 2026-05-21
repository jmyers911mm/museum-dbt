select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
SELECT discount_amount
FROM MUSEUM_DW_PROD.SILVER.silver_pos_tickets
WHERE discount_amount < 0

      
    ) dbt_internal_test