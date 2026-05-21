SELECT *
FROM SEMANTIC_VIEW(museum_dw_prod.gold.sv_museum_operations
  METRICS total_retail_revenue, total_retail_items_sold, retail_aov
  DIMENSIONS retail_items.item_category)
