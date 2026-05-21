SELECT DISTINCT s.payment_method
FROM {{ ref('silver_pos_tickets') }} s
LEFT JOIN {{ ref('dim_payment_method') }} p ON s.payment_method = p.payment_method_id
WHERE p.payment_method_id IS NULL
  AND s.payment_method IS NOT NULL
