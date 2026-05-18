SELECT
    transaction_date || '-' || item_category AS transaction_date_category,
    transaction_date,
    item_category,
    DAYNAME(transaction_date) AS day_of_week,
    COUNT(DISTINCT transaction_id) AS transaction_count,
    SUM(quantity) AS items_sold,
    SUM(total_amount) AS gross_revenue,
    SUM(discount_amount) AS total_discounts,
    SUM(total_amount) - SUM(discount_amount) AS net_revenue,
    ROUND(AVG(total_amount), 2) AS avg_transaction_value,
    COUNT(CASE WHEN is_discounted THEN 1 END) AS discounted_transactions,
    ROUND(COUNT(CASE WHEN is_discounted THEN 1 END)::FLOAT / NULLIF(COUNT(DISTINCT transaction_id), 0) * 100, 2) AS discount_rate_pct,
    CURRENT_TIMESTAMP() AS _loaded_at
FROM {{ ref('silver_pos_retail') }}
GROUP BY transaction_date, item_category
