SELECT DISTINCT s.gate_id
FROM {{ ref('silver_ticket_scans') }} s
LEFT JOIN {{ ref('dim_gate') }} g ON s.gate_id = g.gate_id
WHERE g.gate_id IS NULL
