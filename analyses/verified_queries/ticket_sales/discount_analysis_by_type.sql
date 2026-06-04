SELECT *
FROM SEMANTIC_VIEW(ns11mm_dw_prod.gold.sv_museum_operations
  METRICS ticket_discount_rate, total_ticket_discounts, total_ticket_revenue
  DIMENSIONS ticket_sales.ticket_type)
