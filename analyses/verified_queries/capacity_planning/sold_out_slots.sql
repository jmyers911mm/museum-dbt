SELECT *
FROM SEMANTIC_VIEW(ns11mm_dw_prod.gold.sv_donor_retention
  METRICS total_capacity, total_reserved, avg_utilization
  DIMENSIONS availability.entry_date, availability.entry_window_start, availability.ticket_type, availability.demand_level
  WHERE availability.demand_level IN ('Very High', 'Sold Out')
    AND availability.entry_date >= CURRENT_DATE)
