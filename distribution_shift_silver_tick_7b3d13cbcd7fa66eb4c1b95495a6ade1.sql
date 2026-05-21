select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
WITH counts AS (
    SELECT
        COUNT(*) AS total_rows,
        COUNT(CASE WHEN scan_result = 'VALID' THEN 1 END) AS value_rows
    FROM MUSEUM_DW_PROD.SILVER.silver_ticket_scans
)
SELECT total_rows, value_rows,
       ROUND(value_rows::FLOAT / NULLIF(total_rows, 0) * 100, 2) AS actual_pct
FROM counts
WHERE ROUND(value_rows::FLOAT / NULLIF(total_rows, 0) * 100, 2) < 70
   OR ROUND(value_rows::FLOAT / NULLIF(total_rows, 0) * 100, 2) > 99

      
    ) dbt_internal_test