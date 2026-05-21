
  create or replace   view MUSEUM_DW_PROD.SILVER.stg_pos_retail
  
    
    
(
  
    "TRANSACTION_ID" COMMENT $$$$, 
  
    "TRANSACTION_TIMESTAMP" COMMENT $$$$, 
  
    "ITEM_SKU" COMMENT $$$$, 
  
    "ITEM_NAME" COMMENT $$$$, 
  
    "ITEM_CATEGORY" COMMENT $$$$, 
  
    "QUANTITY" COMMENT $$$$, 
  
    "UNIT_PRICE" COMMENT $$$$, 
  
    "TOTAL_AMOUNT" COMMENT $$$$, 
  
    "DISCOUNT_AMOUNT" COMMENT $$$$, 
  
    "PAYMENT_METHOD" COMMENT $$$$, 
  
    "CASHIER_ID" COMMENT $$$$, 
  
    "TERMINAL_ID" COMMENT $$$$, 
  
    "CUSTOMER_EMAIL" COMMENT $$$$, 
  
    "CUSTOMER_PHONE" COMMENT $$$$, 
  
    "PRODUCT_ID" COMMENT $$$$, 
  
    "PAYMENT_METHOD_ID" COMMENT $$$$, 
  
    "_LOADED_AT" COMMENT $$$$, 
  
    "HASHDIFF" COMMENT $$$$
  
)

   as (
    SELECT
    transaction_id,
    transaction_timestamp,
    item_sku,
    TRIM(item_name) AS item_name,
    TRIM(item_category) AS item_category,
    quantity,
    unit_price,
    total_amount,
    discount_amount,
    payment_method,
    cashier_id,
    terminal_id,
    LOWER(TRIM(customer_email)) AS customer_email,
    TRIM(customer_phone) AS customer_phone,
    product_id,
    payment_method_id,
    _loaded_at,
    MD5(CONCAT_WS('||',
        COALESCE(CAST(item_sku AS VARCHAR), '^^NULL^^'),
        COALESCE(CAST(item_name AS VARCHAR), '^^NULL^^'),
        COALESCE(CAST(item_category AS VARCHAR), '^^NULL^^'),
        COALESCE(CAST(quantity AS VARCHAR), '^^NULL^^'),
        COALESCE(CAST(unit_price AS VARCHAR), '^^NULL^^'),
        COALESCE(CAST(total_amount AS VARCHAR), '^^NULL^^'),
        COALESCE(CAST(discount_amount AS VARCHAR), '^^NULL^^'),
        COALESCE(CAST(payment_method AS VARCHAR), '^^NULL^^'),
        COALESCE(CAST(cashier_id AS VARCHAR), '^^NULL^^'),
        COALESCE(CAST(terminal_id AS VARCHAR), '^^NULL^^'),
        COALESCE(CAST(customer_email AS VARCHAR), '^^NULL^^')
    )) AS hashdiff
FROM MUSEUM_DW_PROD.BRONZE.raw_pos_retail
  );

