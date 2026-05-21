select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      

WITH collision_check AS (
    SELECT
        hashdiff AS check_value,
        'COLLISION' AS issue_type
    FROM MUSEUM_DW_PROD.SILVER.silver_pos_retail
    WHERE hashdiff IS NOT NULL
    GROUP BY hashdiff
    HAVING COUNT(DISTINCT transaction_id) > 1
),
null_check AS (
    SELECT
        transaction_id::VARCHAR AS check_value,
        'NULL_HASH' AS issue_type
    FROM MUSEUM_DW_PROD.SILVER.silver_pos_retail
    WHERE hashdiff IS NULL
)
SELECT * FROM collision_check
UNION ALL
SELECT * FROM null_check


      
    ) dbt_internal_test