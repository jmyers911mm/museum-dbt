SELECT
    vt.scan_date,
    dd.day_name,
    dd.is_weekend,
    vt.scan_hour,
    vt.gate_id,
    vt.visitors_admitted,
    vt.total_scans,
    vt.valid_scan_count,
    vt.rejected_scan_count,
    vt.valid_scan_rate_pct
FROM {{ ref('fct_visitor_traffic') }} vt
LEFT JOIN {{ ref('dim_date') }} dd ON vt.scan_date = dd.date_day
