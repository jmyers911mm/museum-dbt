SELECT *
FROM SEMANTIC_VIEW(museum_dw_prod.gold.sv_museum_operations
  METRICS total_customer_ltv, avg_lifetime_value
  DIMENSIONS customer_ltv.ltv_tier)