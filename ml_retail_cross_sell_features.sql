
  
    

        create or replace transient table MUSEUM_DW_PROD.ML_FEATURES.ml_retail_cross_sell_features
         as
        (

WITH item_pairs AS (
    SELECT
        a.customer_id,
        a.product_id AS product_a,
        b.product_id AS product_b,
        a.transaction_id
    FROM MUSEUM_DW_PROD.GOLD.fct_retail_line_items a
    INNER JOIN MUSEUM_DW_PROD.GOLD.fct_retail_line_items b
        ON a.transaction_id = b.transaction_id
        AND a.product_id < b.product_id
    WHERE a.customer_id IS NOT NULL
),

co_occurrence AS (
    SELECT
        product_a,
        product_b,
        COUNT(DISTINCT transaction_id) AS co_purchase_count,
        COUNT(DISTINCT customer_id) AS unique_customers
    FROM item_pairs
    GROUP BY product_a, product_b
),

product_totals AS (
    SELECT
        product_id,
        COUNT(DISTINCT transaction_id) AS total_transactions
    FROM MUSEUM_DW_PROD.GOLD.fct_retail_line_items
    GROUP BY product_id
)

SELECT
    c.product_a,
    pa.product_name AS product_a_name,
    pa.category AS product_a_category,
    c.product_b,
    pb.product_name AS product_b_name,
    pb.category AS product_b_category,
    c.co_purchase_count,
    c.unique_customers,
    DIV0(c.co_purchase_count, pt_a.total_transactions) AS lift_from_a,
    DIV0(c.co_purchase_count, pt_b.total_transactions) AS lift_from_b,
    DIV0(c.co_purchase_count, LEAST(pt_a.total_transactions, pt_b.total_transactions)) AS jaccard_similarity
FROM co_occurrence c
LEFT JOIN MUSEUM_DW_PROD.GOLD.dim_product pa ON c.product_a = pa.product_id
LEFT JOIN MUSEUM_DW_PROD.GOLD.dim_product pb ON c.product_b = pb.product_id
LEFT JOIN product_totals pt_a ON c.product_a = pt_a.product_id
LEFT JOIN product_totals pt_b ON c.product_b = pt_b.product_id
WHERE c.co_purchase_count >= 2
        );
      
  