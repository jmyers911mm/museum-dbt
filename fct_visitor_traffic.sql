
  
    

        create or replace transient table MUSEUM_DW_PROD.GOLD.fct_visitor_traffic
        copy grants as
        (SELECT
    scan_date || '-' || scan_hour || '-' || gate_id AS scan_date_hour_gate,
    scan_date,
    scan_hour,
    gate_id,
    DAYNAME(scan_date) AS day_of_week,
    SUM(CASE WHEN is_valid_scan THEN visitor_count ELSE 0 END) AS visitors_admitted,
    COUNT(*) AS total_scans,
    COUNT(CASE WHEN is_valid_scan THEN 1 END) AS valid_scan_count,
    COUNT(CASE WHEN NOT is_valid_scan THEN 1 END) AS rejected_scan_count,
    ROUND(COUNT(CASE WHEN is_valid_scan THEN 1 END)::FLOAT / NULLIF(COUNT(*), 0) * 100, 2) AS valid_scan_rate_pct,
    CURRENT_TIMESTAMP() AS _loaded_at
FROM MUSEUM_DW_PROD.SILVER.silver_ticket_scans
GROUP BY scan_date, scan_hour, gate_id
        );
      
  