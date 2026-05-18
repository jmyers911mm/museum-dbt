SELECT
    rp.transaction_date,
    dd.day_name,
    dd.month_name,
    dd.fiscal_year,
    dd.is_weekend,
    rp.item_category,
    rp.transaction_count,
    rp.items_sold,
    rp.gross_revenue,
    rp.total_discounts,
    rp.net_revenue,
    rp.avg_transaction_value,
    rp.discounted_transactions,
    rp.discount_rate_pct
FROM {{ ref('fct_retail_performance') }} rp
LEFT JOIN {{ ref('dim_date') }} dd ON rp.transaction_date = dd.date_day
