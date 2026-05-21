select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
WITH card AS (
    SELECT COUNT(DISTINCT item_category) AS distinct_count
    FROM MUSEUM_DW_PROD.SILVER.silver_pos_retail
)
SELECT distinct_count
FROM card
WHERE distinct_count < 4
   OR distinct_count > 20

      
    ) dbt_internal_test