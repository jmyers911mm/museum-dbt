SELECT *
FROM SEMANTIC_VIEW(museum_dw_prod.gold.sv_museum_operations
  METRICS ticket_aov, avg_tickets_per_transaction
  DIMENSIONS ticket_sales.transaction_date
  WHERE ticket_sales.transaction_date >= DATEADD('MONTH', -3, CURRENT_DATE))