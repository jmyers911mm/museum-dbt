
  
    

        create or replace transient table MUSEUM_DW_PROD.GOLD.fct_ticket_utilization
        copy grants as
        (WITH tickets AS (
    SELECT
        transaction_id,
        transaction_timestamp,
        transaction_date,
        ticket_type,
        visitor_category,
        quantity,
        total_amount,
        is_discounted,
        customer_email,
        has_email,
        _loaded_at
    FROM MUSEUM_DW_PROD.SILVER.silver_pos_tickets
),

scans AS (
    SELECT
        ticket_transaction_id,
        COUNT(*) AS total_scan_attempts,
        COUNT(CASE WHEN is_valid_scan THEN 1 END) AS valid_scans,
        COUNT(CASE WHEN NOT is_valid_scan THEN 1 END) AS rejected_scans,
        MIN(scan_timestamp) AS first_scan_timestamp,
        MAX(scan_timestamp) AS last_scan_timestamp,
        MIN(gate_id) AS entry_gate,
        SUM(CASE WHEN is_valid_scan THEN visitor_count ELSE 0 END) AS visitors_admitted
    FROM MUSEUM_DW_PROD.SILVER.silver_ticket_scans
    GROUP BY ticket_transaction_id
)

SELECT
    t.transaction_id,
    t.transaction_date,
    t.transaction_timestamp,
    t.ticket_type,
    t.visitor_category,
    t.quantity,
    t.total_amount,
    t.is_discounted,
    t.has_email,
    CASE WHEN s.ticket_transaction_id IS NOT NULL THEN TRUE ELSE FALSE END AS was_scanned,
    COALESCE(s.visitors_admitted, 0) AS visitors_admitted,
    s.entry_gate,
    s.first_scan_timestamp,
    s.last_scan_timestamp,
    s.total_scan_attempts,
    s.valid_scans,
    s.rejected_scans,
    CASE
        WHEN s.ticket_transaction_id IS NULL THEN 'Unused'
        WHEN s.valid_scans > 0 THEN 'Used'
        ELSE 'Rejected'
    END AS utilization_status,
    t._loaded_at
FROM tickets t
LEFT JOIN scans s ON t.transaction_id = s.ticket_transaction_id
        );
      
  