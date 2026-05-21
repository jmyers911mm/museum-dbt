-- Validates that all ticket types in fct_ticket_sales exist in ref_ticket_types seed
-- Catches drift between actual data and reference seed
SELECT DISTINCT t.ticket_type
FROM {{ ref('fct_ticket_sales') }} t
LEFT JOIN {{ ref('ref_ticket_types') }} r ON t.ticket_type = r.ticket_type_id
WHERE r.ticket_type_id IS NULL
  AND t.ticket_type IS NOT NULL
