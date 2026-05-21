
  
    

        create or replace transient table MUSEUM_DW_PROD.GOLD.rpt_visitor_traffic
        copy grants as
        (SELECT
    vt.scan_date,
    dd.day_name,
    dd.month_name,
    dd.fiscal_year,
    dd.is_weekend,
    vt.scan_hour,
    vt.gate_id,
    dg.gate_name,
    dg.location AS gate_location,
    dg.is_members_only,
    dg.is_primary_entrance,
    vt.visitors_admitted,
    vt.total_scans,
    vt.valid_scan_count,
    vt.rejected_scan_count,
    vt.valid_scan_rate_pct,
    ts.tickets_for_gate,
    ts.ticket_utilization_rate
FROM MUSEUM_DW_PROD.GOLD.fct_visitor_traffic vt
LEFT JOIN MUSEUM_DW_PROD.GOLD.dim_date dd ON vt.scan_date = dd.date_day
LEFT JOIN MUSEUM_DW_PROD.GOLD.dim_gate dg ON vt.gate_id = dg.gate_id
LEFT JOIN (
    SELECT
        entry_gate,
        scan_date::DATE AS scan_day,
        COUNT(*) AS tickets_for_gate,
        DIV0(SUM(CASE WHEN was_scanned THEN 1 ELSE 0 END), COUNT(*)) AS ticket_utilization_rate
    FROM MUSEUM_DW_PROD.GOLD.fct_ticket_sales
    WHERE entry_gate IS NOT NULL
    GROUP BY entry_gate, scan_date::DATE
) ts ON vt.gate_id = ts.entry_gate AND vt.scan_date = ts.scan_day
        );
      
  