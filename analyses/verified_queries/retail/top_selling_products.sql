SELECT *
FROM SEMANTIC_VIEW(museum_dw_prod.gold.sv_museum_operations
  METRICS total_retail_revenue, total_retail_items_sold
  DIMENSIONS dim_product.product_name, dim_product.category, dim_product.price_tier)
