SELECT *
FROM SEMANTIC_VIEW(museum_dw_prod.gold.sv_museum_operations
  METRICS total_daily_revenue, total_daily_visitors
  DIMENSIONS daily_ops.day_of_week
  WHERE daily_ops.visit_date >= DATE_TRUNC('YEAR', CURRENT_DATE)
    AND daily_ops.visit_date < CURRENT_DATE)