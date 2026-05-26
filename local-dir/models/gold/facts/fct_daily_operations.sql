{{
    config(
        unique_key='visit_date',
        incremental_strategy='merge',
        on_schema_change='append_new_columns',
        cluster_by=['visit_date'],
        tags=['intraday', 'critical'],
        query_tag='dbt_museum_gold_intraday'
    )
}}

WITH ticket_sales AS (
    SELECT
        transaction_date AS visit_date,
        COUNT(DISTINCT transaction_id) AS ticket_transactions,
        SUM(quantity) AS tickets_sold,
        SUM(total_amount) AS ticket_revenue,
        SUM(discount_amount) AS ticket_discounts,
        COUNT(DISTINCT CASE WHEN has_email THEN customer_email END) AS identified_visitors
    FROM {{ ref('silver_pos_tickets') }}
    {% if is_incremental() %}
    WHERE _loaded_at > (SELECT MAX(_loaded_at) FROM {{ this }})
    {% endif %}
    GROUP BY 1
),

scans AS (
    SELECT
        scan_date AS visit_date,
        SUM(CASE WHEN is_valid_scan THEN visitor_count ELSE 0 END) AS total_visitors_admitted,
        COUNT(CASE WHEN is_valid_scan THEN 1 END) AS valid_scans,
        COUNT(CASE WHEN NOT is_valid_scan THEN 1 END) AS rejected_scans,
        COUNT(DISTINCT gate_id) AS gates_active
    FROM {{ ref('silver_ticket_scans') }}
    {% if is_incremental() %}
    WHERE _loaded_at > (SELECT MAX(_loaded_at) FROM {{ this }})
    {% endif %}
    GROUP BY 1
),

retail AS (
    SELECT
        transaction_date AS visit_date,
        COUNT(DISTINCT transaction_id) AS retail_transactions,
        SUM(total_amount) AS retail_revenue,
        SUM(quantity) AS items_sold,
        SUM(discount_amount) AS retail_discounts
    FROM {{ ref('silver_pos_retail') }}
    {% if is_incremental() %}
    WHERE _loaded_at > (SELECT MAX(_loaded_at) FROM {{ this }})
    {% endif %}
    GROUP BY 1
)

SELECT
    COALESCE(t.visit_date, s.visit_date, r.visit_date) AS visit_date,
    DAYNAME(COALESCE(t.visit_date, s.visit_date, r.visit_date)) AS day_of_week,
    COALESCE(s.total_visitors_admitted, 0) AS total_visitors,
    COALESCE(s.valid_scans, 0) AS valid_scans,
    COALESCE(s.rejected_scans, 0) AS rejected_scans,
    COALESCE(s.gates_active, 0) AS gates_active,
    COALESCE(t.ticket_transactions, 0) AS ticket_transactions,
    COALESCE(t.tickets_sold, 0) AS tickets_sold,
    COALESCE(t.ticket_revenue, 0) AS ticket_revenue,
    COALESCE(t.ticket_discounts, 0) AS ticket_discounts,
    COALESCE(t.identified_visitors, 0) AS identified_ticket_buyers,
    COALESCE(r.retail_transactions, 0) AS retail_transactions,
    COALESCE(r.items_sold, 0) AS retail_items_sold,
    COALESCE(r.retail_revenue, 0) AS retail_revenue,
    COALESCE(r.retail_discounts, 0) AS retail_discounts,
    COALESCE(t.ticket_revenue, 0) + COALESCE(r.retail_revenue, 0) AS total_revenue,
    CASE WHEN COALESCE(s.total_visitors_admitted, 0) > 0
        THEN ROUND(COALESCE(r.retail_revenue, 0) / s.total_visitors_admitted, 2)
        ELSE 0 END AS retail_revenue_per_visitor,
    CURRENT_TIMESTAMP() AS _loaded_at
FROM ticket_sales t
FULL OUTER JOIN scans s ON t.visit_date = s.visit_date
FULL OUTER JOIN retail r ON COALESCE(t.visit_date, s.visit_date) = r.visit_date
