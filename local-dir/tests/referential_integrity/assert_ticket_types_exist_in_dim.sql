SELECT DISTINCT s.ticket_type
FROM {{ ref('silver_pos_tickets') }} s
LEFT JOIN {{ ref('dim_ticket_type') }} t ON s.ticket_type = t.ticket_type_id
WHERE t.ticket_type_id IS NULL
