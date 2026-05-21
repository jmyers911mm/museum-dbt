
  create or replace   view MUSEUM_DW_PROD.SILVER.stg_ticket_scans
  
    
    
(
  
    "SCAN_ID" COMMENT $$$$, 
  
    "SCAN_TIMESTAMP" COMMENT $$$$, 
  
    "TICKET_BARCODE" COMMENT $$$$, 
  
    "TICKET_TRANSACTION_ID" COMMENT $$$$, 
  
    "GATE_ID" COMMENT $$$$, 
  
    "SCAN_RESULT" COMMENT $$$$, 
  
    "TICKET_TYPE" COMMENT $$$$, 
  
    "VISITOR_COUNT" COMMENT $$$$, 
  
    "_LOADED_AT" COMMENT $$$$, 
  
    "HASHDIFF" COMMENT $$$$
  
)

   as (
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
FROM MUSEUM_DW_PROD.BRONZE.raw_ticket_scans
  );

