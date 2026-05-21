
  
    

        create or replace transient table MUSEUM_DW_PROD.GOLD.rpt_retail_performance
        copy grants as
        (SELECT
    r.transaction_id,
    r.transaction_date,
    dd.day_name,
    dd.month_name,
    dd.fiscal_year,
    dd.is_weekend,
    r.item_sku,
    r.item_name,
    r.item_category,
    dp.product_group,
    dp.price_tier AS product_price_tier,
    dp.standard_price AS product_standard_price,
    r.quantity,
    r.unit_price,
    r.total_amount,
    r.discount_amount,
    r.is_discounted,
    r.discount_pct,
    r.payment_method_id,
    pm.payment_method_name,
    pm.payment_category,
    pm.is_electronic,
    r.customer_id,
    c.full_name AS customer_name,
    c.customer_segment,
    c.membership_type AS customer_membership_type
FROM MUSEUM_DW_PROD.GOLD.fct_retail_line_items r
LEFT JOIN MUSEUM_DW_PROD.GOLD.dim_date dd ON r.transaction_date::DATE = dd.date_day
LEFT JOIN MUSEUM_DW_PROD.GOLD.dim_product dp ON r.product_id = dp.product_id
LEFT JOIN MUSEUM_DW_PROD.GOLD.dim_payment_method pm ON r.payment_method_id = pm.payment_method_id
LEFT JOIN MUSEUM_DW_PROD.GOLD.dim_customer c ON r.customer_id = c.customer_id
        );
      
  