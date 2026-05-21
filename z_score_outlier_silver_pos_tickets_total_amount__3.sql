select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
WITH stats AS (
    SELECT
        AVG(total_amount) AS mean_val,
        STDDEV(total_amount) AS stddev_val
    FROM MUSEUM_DW_PROD.SILVER.silver_pos_tickets
    WHERE total_amount IS NOT NULL
)
SELECT total_amount
FROM MUSEUM_DW_PROD.SILVER.silver_pos_tickets, stats
WHERE stats.stddev_val > 0
  AND ABS((total_amount - stats.mean_val) / stats.stddev_val) > 3

      
    ) dbt_internal_test