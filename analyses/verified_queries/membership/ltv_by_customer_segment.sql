SELECT *
FROM SEMANTIC_VIEW(ns11mm_dw_prod.gold.sv_museum_operations
  METRICS avg_lifetime_value, total_customers
  DIMENSIONS customers.customer_segment)
