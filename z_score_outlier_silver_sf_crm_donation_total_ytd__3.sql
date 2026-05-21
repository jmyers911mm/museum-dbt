select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
WITH stats AS (
    SELECT
        AVG(donation_total_ytd) AS mean_val,
        STDDEV(donation_total_ytd) AS stddev_val
    FROM MUSEUM_DW_PROD.SILVER.silver_sf_crm
    WHERE donation_total_ytd IS NOT NULL
)
SELECT donation_total_ytd
FROM MUSEUM_DW_PROD.SILVER.silver_sf_crm, stats
WHERE stats.stddev_val > 0
  AND ABS((donation_total_ytd - stats.mean_val) / stats.stddev_val) > 3

      
    ) dbt_internal_test