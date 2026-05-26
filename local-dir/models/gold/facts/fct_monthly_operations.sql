WITH daily AS (
    SELECT
        ops.visit_date,
        dd.fiscal_year,
        dd.fiscal_quarter,
        dd.year_num,
        dd.month_num,
        dd.month_name,
        dd.is_weekend,
        ops.total_visitors,
        ops.ticket_transactions,
        ops.tickets_sold,
        ops.ticket_revenue,
        ops.ticket_discounts,
        ops.retail_transactions,
        ops.retail_items_sold,
        ops.retail_revenue,
        ops.retail_discounts,
        ops.total_revenue,
        ops.valid_scans,
        ops.rejected_scans,
        ops.identified_ticket_buyers,
        ops._loaded_at
    FROM {{ ref('fct_daily_operations') }} ops
    LEFT JOIN {{ ref('dim_date') }} dd ON ops.visit_date = dd.date_day
)

SELECT
    fiscal_year || '-' || LPAD(month_num, 2, '0') AS fiscal_year_month,
    fiscal_year,
    fiscal_quarter,
    year_num,
    month_num,
    month_name,
    COUNT(DISTINCT visit_date) AS operating_days,
    COUNT(DISTINCT CASE WHEN is_weekend THEN visit_date END) AS weekend_days,
    SUM(total_visitors) AS total_visitors,
    ROUND(AVG(total_visitors), 0) AS avg_daily_visitors,
    MAX(total_visitors) AS peak_day_visitors,
    SUM(ticket_transactions) AS ticket_transactions,
    SUM(tickets_sold) AS tickets_sold,
    SUM(ticket_revenue) AS ticket_revenue,
    SUM(ticket_discounts) AS ticket_discounts,
    SUM(retail_transactions) AS retail_transactions,
    SUM(retail_items_sold) AS retail_items_sold,
    SUM(retail_revenue) AS retail_revenue,
    SUM(retail_discounts) AS retail_discounts,
    SUM(total_revenue) AS total_revenue,
    ROUND(SUM(total_revenue) / NULLIF(SUM(total_visitors), 0), 2) AS revenue_per_visitor,
    SUM(valid_scans) AS valid_scans,
    SUM(rejected_scans) AS rejected_scans,
    CURRENT_TIMESTAMP() AS _loaded_at
FROM daily
GROUP BY fiscal_year, fiscal_quarter, year_num, month_num, month_name
