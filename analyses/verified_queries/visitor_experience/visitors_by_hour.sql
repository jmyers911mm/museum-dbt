SELECT *
FROM SEMANTIC_VIEW(ns11mm_dw_prod.gold.sv_museum_operations
  METRICS total_gate_admissions
  DIMENSIONS traffic.scan_hour)
