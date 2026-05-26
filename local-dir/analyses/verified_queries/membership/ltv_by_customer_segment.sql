SELECT *
FROM SEMANTIC_VIEW(museum_dw_prod.gold.sv_museum_operations
  METRICS avg_lifetime_value, total_customers
  DIMENSIONS customers.customer_segment)
