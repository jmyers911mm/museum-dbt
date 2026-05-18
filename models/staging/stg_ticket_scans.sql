SELECT
    scan_id,
    scan_timestamp,
    ticket_barcode,
    ticket_transaction_id,
    gate_id,
    scan_result,
    ticket_type,
    visitor_count,
    _loaded_at,
    MD5(CONCAT_WS('||',
        COALESCE(CAST(ticket_barcode AS VARCHAR), '^^NULL^^'),
        COALESCE(CAST(ticket_transaction_id AS VARCHAR), '^^NULL^^'),
        COALESCE(CAST(gate_id AS VARCHAR), '^^NULL^^'),
        COALESCE(CAST(scan_result AS VARCHAR), '^^NULL^^'),
        COALESCE(CAST(ticket_type AS VARCHAR), '^^NULL^^'),
        COALESCE(CAST(visitor_count AS VARCHAR), '^^NULL^^')
    )) AS hashdiff
FROM {{ source('bronze', 'raw_ticket_scans') }}
