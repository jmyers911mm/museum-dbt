WITH source AS (
    SELECT *
    FROM {{ ref('silver_pos_retail') }}
)

SELECT DISTINCT
    item_sku AS product_id,
    item_name AS product_name,
    item_category AS category,
    unit_price AS standard_price,
    CASE
        WHEN unit_price >= 30 THEN 'Premium'
        WHEN unit_price >= 15 THEN 'Mid-Range'
        ELSE 'Value'
    END AS price_tier,
    CASE item_category
        WHEN 'Books' THEN 'Educational'
        WHEN 'Art Prints' THEN 'Educational'
        WHEN 'Kids' THEN 'Family'
        WHEN 'Games' THEN 'Family'
        WHEN 'Souvenirs' THEN 'Keepsake'
        WHEN 'Accessories' THEN 'Wearable'
        WHEN 'Jewelry' THEN 'Wearable'
        ELSE 'Other'
    END AS product_group,
    CURRENT_TIMESTAMP() AS _loaded_at
FROM source
