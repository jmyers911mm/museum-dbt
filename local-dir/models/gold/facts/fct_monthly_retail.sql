WITH daily AS (
    SELECT
        rp.transaction_date,
        dd.fiscal_year,
        dd.fiscal_quarter,
        dd.year_num,
        dd.month_num,
        dd.month_name,
        rp.item_category,
        rp.transaction_count,
        rp.items_sold,
        rp.gross_revenue,
        rp.total_discounts,
        rp.net_revenue,
        rp.discounted_transactions,
        rp._loaded_at
    FROM {{ ref('fct_retail_performance') }} rp
    LEFT JOIN {{ ref('dim_date') }} dd ON rp.transaction_date = dd.date_day
)

SELECT
    year_num || '-' || LPAD(month_num, 2, '0') || '-' || item_category AS month_category,
    fiscal_year,
    fiscal_quarter,
    year_num,
    month_num,
    month_name,
    item_category,
    COUNT(DISTINCT transaction_date) AS selling_days,
    SUM(transaction_count) AS transaction_count,
    SUM(items_sold) AS items_sold,
    SUM(gross_revenue) AS gross_revenue,
    SUM(total_discounts) AS total_discounts,
    SUM(net_revenue) AS net_revenue,
    ROUND(SUM(net_revenue) / NULLIF(COUNT(DISTINCT transaction_date), 0), 2) AS avg_daily_revenue,
    ROUND(SUM(items_sold)::FLOAT / NULLIF(SUM(transaction_count), 0), 2) AS avg_items_per_transaction,
    SUM(discounted_transactions) AS discounted_transactions,
    CURRENT_TIMESTAMP() AS _loaded_at
FROM daily
GROUP BY fiscal_year, fiscal_quarter, year_num, month_num, month_name, item_category
