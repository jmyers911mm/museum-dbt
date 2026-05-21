SELECT *
FROM SEMANTIC_VIEW(museum_dw_prod.gold.sv_museum_operations
  METRICS total_daily_revenue
  DIMENSIONS daily_ops.visit_date
  WHERE daily_ops.visit_date >= DATE_TRUNC('MONTH', CURRENT_DATE)
    AND daily_ops.visit_date < CURRENT_DATE)