
  
    

        create or replace transient table MUSEUM_DW_PROD.GOLD.fct_retail_line_items
        copy grants as
        (select * from (
              

WITH retail AS (
    SELECT
        transaction_id,
        transaction_timestamp,
        transaction_date,
        item_sku,
        item_name,
        item_category,
        quantity,
        unit_price,
        total_amount,
        discount_amount,
        is_discounted,
        discount_pct,
        payment_method,
        payment_method_id,
        product_id,
        customer_email,
        customer_phone,
        has_phone
    FROM MUSEUM_DW_PROD.SILVER.silver_pos_retail
),

customer_lookup AS (
    SELECT
        customer_id,
        primary_email,
        primary_phone
    FROM MUSEUM_DW_PROD.GOLD.dim_customer
)

SELECT
    r.transaction_id,
    r.transaction_timestamp,
    r.transaction_date,
    r.item_sku,
    r.item_name,
    r.item_category,
    r.quantity,
    r.unit_price,
    r.total_amount,
    r.discount_amount,
    r.is_discounted,
    r.discount_pct,
    r.payment_method,
    r.payment_method_id,
    r.product_id,
    r.customer_email,
    r.customer_phone,
    COALESCE(ce.customer_id, cp.customer_id) AS customer_id,
    CURRENT_TIMESTAMP() AS _loaded_at
FROM retail r
LEFT JOIN customer_lookup ce ON r.customer_email = ce.primary_email AND r.customer_email IS NOT NULL
LEFT JOIN customer_lookup cp ON r.customer_phone = cp.primary_phone AND r.customer_phone IS NOT NULL AND ce.customer_id IS NULL
              ) order by (transaction_date, item_category)
        );
      alter  table MUSEUM_DW_PROD.GOLD.fct_retail_line_items cluster by (transaction_date, item_category);
  