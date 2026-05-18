SELECT DISTINCT s.item_sku
FROM {{ ref('silver_pos_retail') }} s
LEFT JOIN {{ ref('dim_product') }} p ON s.item_sku = p.product_id
WHERE p.product_id IS NULL
