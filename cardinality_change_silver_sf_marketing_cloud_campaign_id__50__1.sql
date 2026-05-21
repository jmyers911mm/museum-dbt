select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
WITH card AS (
    SELECT COUNT(DISTINCT campaign_id) AS distinct_count
    FROM MUSEUM_DW_PROD.SILVER.silver_sf_marketing_cloud
)
SELECT distinct_count
FROM card
WHERE distinct_count < 1
   OR distinct_count > 50

      
    ) dbt_internal_test