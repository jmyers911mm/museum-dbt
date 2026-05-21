WITH methods AS (
    SELECT DISTINCT payment_method FROM {{ ref('silver_pos_tickets') }}
    UNION
    SELECT DISTINCT payment_method FROM {{ ref('silver_pos_retail') }}
)

SELECT
    payment_method AS payment_method_id,
    payment_method AS payment_method_name,
    CASE payment_method
        WHEN 'Credit Card' THEN 'Card'
        WHEN 'Debit Card' THEN 'Card'
        WHEN 'Cash' THEN 'Cash'
        WHEN 'Mobile Pay' THEN 'Digital'
        ELSE 'Other'
    END AS payment_category,
    CASE payment_method
        WHEN 'Credit Card' THEN TRUE
        WHEN 'Debit Card' THEN TRUE
        WHEN 'Mobile Pay' THEN TRUE
        ELSE FALSE
    END AS is_electronic
FROM methods
