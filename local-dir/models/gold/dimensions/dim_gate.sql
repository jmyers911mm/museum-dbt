WITH gates AS (
    SELECT DISTINCT gate_id
    FROM {{ ref('silver_ticket_scans') }}
)

SELECT
    gate_id,
    CASE gate_id
        WHEN 'GATE-MAIN' THEN 'Main Entrance'
        WHEN 'GATE-NORTH' THEN 'North Wing Entrance'
        WHEN 'GATE-SOUTH' THEN 'South Wing Entrance'
        WHEN 'GATE-MEMBER' THEN 'Members Only Entrance'
        ELSE 'Unknown'
    END AS gate_name,
    CASE gate_id
        WHEN 'GATE-MAIN' THEN 'Lobby'
        WHEN 'GATE-NORTH' THEN 'North Wing'
        WHEN 'GATE-SOUTH' THEN 'South Wing'
        WHEN 'GATE-MEMBER' THEN 'East Wing'
        ELSE 'Unknown'
    END AS location,
    CASE gate_id
        WHEN 'GATE-MEMBER' THEN TRUE
        ELSE FALSE
    END AS is_members_only,
    CASE gate_id
        WHEN 'GATE-MAIN' THEN TRUE
        ELSE FALSE
    END AS is_primary_entrance
FROM gates
