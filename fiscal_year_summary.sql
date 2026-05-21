SELECT *
FROM SEMANTIC_VIEW(museum_dw_prod.gold.sv_museum_operations
  METRICS total_daily_revenue, total_daily_visitors, daily_revenue_per_visitor
  DIMENSIONS dates.fiscal_year)