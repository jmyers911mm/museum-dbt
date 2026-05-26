SELECT *
FROM SEMANTIC_VIEW(museum_dw_prod.gold.sv_museum_operations
  METRICS total_gate_admissions
  DIMENSIONS dim_gate.gate_name, dim_gate.location, dim_gate.is_members_only)
