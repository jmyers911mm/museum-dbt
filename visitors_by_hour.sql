SELECT *
FROM SEMANTIC_VIEW(museum_dw_prod.gold.sv_museum_operations
  METRICS total_gate_admissions
  DIMENSIONS traffic.scan_hour)