select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
WITH rates AS (
    SELECT
        COUNT(*) AS total_rows,
        COUNT(CASE WHEN customer_email IS NULL THEN 1 END) AS null_rows
    FROM MUSEUM_DW_PROD.SILVER.silver_pos_tickets
)
SELECT total_rows, null_rows,
       ROUND(null_rows::FLOAT / NULLIF(total_rows, 0) * 100, 2) AS null_pct
FROM rates
WHERE ROUND(null_rows::FLOAT / NULLIF(total_rows, 0) * 100, 2) > 80

      
    ) dbt_internal_test