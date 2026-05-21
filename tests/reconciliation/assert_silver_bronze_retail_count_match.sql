WITH silver_total AS (
    SELECT COUNT(*) AS silver_count
    FROM {{ ref('silver_pos_retail') }}
),
bronze_total AS (
    SELECT COUNT(*) AS bronze_count
    FROM {{ source('bronze', 'raw_pos_retail') }}
)
SELECT
    s.silver_count,
    b.bronze_count
FROM silver_total s
CROSS JOIN bronze_total b
WHERE s.silver_count != b.bronze_count
