SELECT *
FROM SEMANTIC_VIEW(ns11mm_dw_prod.gold.sv_museum_operations
  METRICS ticket_utilization_rate, total_visitors_from_tickets
  DIMENSIONS ticket_sales.entry_gate)
