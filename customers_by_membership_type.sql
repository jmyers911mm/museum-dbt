SELECT *
FROM SEMANTIC_VIEW(museum_dw_prod.gold.sv_museum_operations
  METRICS total_customers
  DIMENSIONS customers.membership_type, customers.customer_segment)