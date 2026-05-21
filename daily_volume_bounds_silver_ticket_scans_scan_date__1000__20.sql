select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
WITH daily_counts AS (
    SELECT
        scan_date AS day_val,
        COUNT(*) AS row_count
    FROM MUSEUM_DW_PROD.SILVER.silver_ticket_scans
    GROUP BY 1
)
SELECT day_val, row_count
FROM daily_counts
WHERE row_count < 20
   OR row_count > 1000

      
    ) dbt_internal_test