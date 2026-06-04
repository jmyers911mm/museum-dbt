SELECT *
FROM SEMANTIC_VIEW(ns11mm_dw_prod.gold.sv_museum_operations
  METRICS net_ticket_revenue, net_retail_revenue
  DIMENSIONS dates.month_name
  WHERE daily_ops.visit_date >= DATEADD('MONTH', -6, CURRENT_DATE))
