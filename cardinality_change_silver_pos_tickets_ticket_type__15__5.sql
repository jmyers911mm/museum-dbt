select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
WITH card AS (
    SELECT COUNT(DISTINCT ticket_type) AS distinct_count
    FROM MUSEUM_DW_PROD.SILVER.silver_pos_tickets
)
SELECT distinct_count
FROM card
WHERE distinct_count < 5
   OR distinct_count > 15

      
    ) dbt_internal_test