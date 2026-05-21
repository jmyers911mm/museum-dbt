
  
    

        create or replace transient table MUSEUM_DW_PROD.GOLD.dim_payment_method
          
  (
    payment_method_id VARCHAR,
    payment_method_name VARCHAR,
    payment_category VARCHAR,
    is_electronic BOOLEAN
    
    )

          
        
        copy grants as
        (
    select payment_method_id, payment_method_name, payment_category, is_electronic
    from (
        WITH methods AS (
    SELECT DISTINCT payment_method FROM MUSEUM_DW_PROD.SILVER.silver_pos_tickets
    UNION
    SELECT DISTINCT payment_method FROM MUSEUM_DW_PROD.SILVER.silver_pos_retail
)

SELECT
    payment_method AS payment_method_id,
    payment_method AS payment_method_name,
    CASE payment_method
        WHEN 'Credit Card' THEN 'Card'
        WHEN 'Debit Card' THEN 'Card'
        WHEN 'Cash' THEN 'Cash'
        WHEN 'Mobile Pay' THEN 'Digital'
        ELSE 'Other'
    END AS payment_category,
    CASE payment_method
        WHEN 'Credit Card' THEN TRUE
        WHEN 'Debit Card' THEN TRUE
        WHEN 'Mobile Pay' THEN TRUE
        ELSE FALSE
    END AS is_electronic
FROM methods
    ) as model_subq
        );
      
  