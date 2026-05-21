
  create or replace   view MUSEUM_DW_PROD.SILVER.stg_pos_tickets
  
    
    
(
  
    "TRANSACTION_ID" COMMENT $$$$, 
  
    "TRANSACTION_TIMESTAMP" COMMENT $$$$, 
  
    "ENTRY_TIME_PURCHASED" COMMENT $$$$, 
  
    "ENTRY_DATE" COMMENT $$$$, 
  
    "ENTRY_WINDOW_START" COMMENT $$$$, 
  
    "ENTRY_WINDOW_END" COMMENT $$$$, 
  
    "TICKET_TYPE" COMMENT $$$$, 
  
    "MAPPED_TICKET_TYPE" COMMENT $$$$, 
  
    "QUANTITY" COMMENT $$$$, 
  
    "UNIT_PRICE" COMMENT $$$$, 
  
    "TOTAL_AMOUNT" COMMENT $$$$, 
  
    "DISCOUNT_CODE" COMMENT $$$$, 
  
    "DISCOUNT_AMOUNT" COMMENT $$$$, 
  
    "PAYMENT_METHOD" COMMENT $$$$, 
  
    "CASHIER_ID" COMMENT $$$$, 
  
    "TERMINAL_ID" COMMENT $$$$, 
  
    "CUSTOMER_EMAIL" COMMENT $$$$, 
  
    "CUSTOMER_PHONE" COMMENT $$$$, 
  
    "TICKET_NUMBER" COMMENT $$$$, 
  
    "PAYMENT_METHOD_ID" COMMENT $$$$, 
  
    "_LOADED_AT" COMMENT $$$$, 
  
    "HASHDIFF" COMMENT $$$$
  
)

   as (
    

SELECT
    transaction_id,
    transaction_timestamp,
    entry_time_purchased,
    DATE_TRUNC('day', entry_time_purchased)::DATE AS entry_date,
    entry_time_purchased::TIME AS entry_window_start,
    TIMEADD('minute', 30, entry_time_purchased::TIME) AS entry_window_end,
    ticket_type,
    CASE ticket_type
        WHEN 'General Admission Adult' THEN 'Museum General Admission'
        WHEN 'General Admission Senior' THEN 'Museum General Admission'
        WHEN 'General Admission Child' THEN 'Museum General Admission'
        WHEN 'Free Member Entry' THEN 'Museum Free Admission'
        WHEN 'Member Guest' THEN 'Museum Free Admission'
        WHEN 'Family Pack (4)' THEN 'Museum General Admission'
        WHEN 'School Group' THEN 'Museum Admission Special'
        WHEN 'Special Exhibition' THEN 'Museum Admission Special'
        ELSE 'Museum General Admission'
    END AS mapped_ticket_type,
    quantity,
    unit_price,
    total_amount,
    discount_code,
    discount_amount,
    payment_method,
    cashier_id,
    terminal_id,
    LOWER(TRIM(customer_email)) AS customer_email,
    TRIM(customer_phone) AS customer_phone,
    ticket_number,
    payment_method_id,
    _loaded_at,
    
    MD5(CONCAT_WS('||',
        
        COALESCE(CAST(ticket_type AS VARCHAR), '^^NULL^^'),
        
        COALESCE(CAST(entry_time_purchased AS VARCHAR), '^^NULL^^'),
        
        COALESCE(CAST(quantity AS VARCHAR), '^^NULL^^'),
        
        COALESCE(CAST(unit_price AS VARCHAR), '^^NULL^^'),
        
        COALESCE(CAST(total_amount AS VARCHAR), '^^NULL^^'),
        
        COALESCE(CAST(discount_code AS VARCHAR), '^^NULL^^'),
        
        COALESCE(CAST(discount_amount AS VARCHAR), '^^NULL^^'),
        
        COALESCE(CAST(payment_method AS VARCHAR), '^^NULL^^'),
        
        COALESCE(CAST(cashier_id AS VARCHAR), '^^NULL^^'),
        
        COALESCE(CAST(terminal_id AS VARCHAR), '^^NULL^^'),
        
        COALESCE(CAST(customer_email AS VARCHAR), '^^NULL^^')
        
    ))
 AS hashdiff
FROM MUSEUM_DW_PROD.BRONZE.raw_pos_tickets
  );

