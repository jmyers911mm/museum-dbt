SELECT *
FROM SEMANTIC_VIEW(museum_dw_prod.gold.sv_donor_retention
  METRICS total_capacity, total_reserved, total_available, avg_utilization
  DIMENSIONS availability.entry_date, availability.ticket_type
  WHERE availability.entry_date >= CURRENT_DATE
    AND availability.entry_date <= DATEADD('DAY', 7, CURRENT_DATE))