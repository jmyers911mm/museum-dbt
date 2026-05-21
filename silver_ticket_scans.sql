
  
    

        create or replace transient table MUSEUM_DW_PROD.SILVER.silver_ticket_scans
        copy grants as
        (SELECT
    scan_id,
    scan_timestamp,
    DATE_TRUNC('day', scan_timestamp) AS scan_date,
    EXTRACT(HOUR FROM scan_timestamp) AS scan_hour,
    ticket_barcode,
    ticket_transaction_id,
    gate_id,
    scan_result,
    CASE WHEN scan_result = 'VALID' THEN TRUE ELSE FALSE END AS is_valid_scan,
    ticket_type,
    visitor_count,
    hashdiff,
    _loaded_at
FROM MUSEUM_DW_PROD.SILVER.stg_ticket_scans
        );
      
  