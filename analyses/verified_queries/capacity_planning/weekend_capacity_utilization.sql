SELECT *
FROM SEMANTIC_VIEW(ns11mm_dw_prod.gold.sv_donor_retention
  METRICS avg_utilization, total_capacity, total_reserved
  DIMENSIONS availability.is_weekend, availability.ticket_type
  WHERE availability.entry_date >= CURRENT_DATE)
