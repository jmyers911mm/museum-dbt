SELECT *
FROM SEMANTIC_VIEW(museum_dw_prod.gold.sv_museum_operations
  METRICS total_ticket_revenue
  DIMENSIONS dim_payment_method.payment_method_name, dim_payment_method.payment_category)
