
  
    

        create or replace transient table MUSEUM_DW_PROD.GOLD.dim_gate
          
  (
    gate_id VARCHAR,
    gate_name VARCHAR,
    location VARCHAR,
    is_members_only BOOLEAN,
    is_primary_entrance BOOLEAN
    
    )

          
        
        copy grants as
        (
    select gate_id, gate_name, location, is_members_only, is_primary_entrance
    from (
        WITH gates AS (
    SELECT DISTINCT gate_id
    FROM MUSEUM_DW_PROD.SILVER.silver_ticket_scans
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
    ) as model_subq
        );
      
  