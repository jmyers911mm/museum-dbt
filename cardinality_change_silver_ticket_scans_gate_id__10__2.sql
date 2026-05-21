select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
WITH card AS (
    SELECT COUNT(DISTINCT gate_id) AS distinct_count
    FROM MUSEUM_DW_PROD.SILVER.silver_ticket_scans
)
SELECT distinct_count
FROM card
WHERE distinct_count < 2
   OR distinct_count > 10

      
    ) dbt_internal_test