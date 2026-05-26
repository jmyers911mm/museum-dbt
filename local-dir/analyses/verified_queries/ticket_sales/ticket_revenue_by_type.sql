SELECT *
FROM SEMANTIC_VIEW(museum_dw_prod.gold.sv_museum_operations
  METRICS total_ticket_revenue, total_tickets_sold, ticket_aov
  DIMENSIONS ticket_sales.ticket_type)
