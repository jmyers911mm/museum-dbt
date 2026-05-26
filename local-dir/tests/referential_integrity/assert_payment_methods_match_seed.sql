-- Validates that all payment methods in fct_ticket_sales exist in ref_payment_methods seed
SELECT DISTINCT t.payment_method_id
FROM {{ ref('fct_ticket_sales') }} t
LEFT JOIN {{ ref('ref_payment_methods') }} r ON t.payment_method_id = r.payment_method_id
WHERE r.payment_method_id IS NULL
  AND t.payment_method_id IS NOT NULL
