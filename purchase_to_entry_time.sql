SELECT *
FROM SEMANTIC_VIEW(museum_dw_prod.gold.sv_museum_operations
  METRICS avg_purchase_to_entry_minutes
  DIMENSIONS ticket_sales.ticket_type, ticket_sales.visitor_category)