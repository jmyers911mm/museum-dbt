{{
    config(
        materialized='table',
        schema='GOLD',
        tags=['daily', 'critical']
    )
}}

WITH daily_revenue AS (
    SELECT
        ops.visit_date,
        dd.year_num,
        dd.week_of_year,
        dd.fiscal_year,
        dd.fiscal_quarter,
        dd.is_weekend,
        ops.ticket_revenue,
        ops.ticket_discounts,
        ops.tickets_sold,
        ops.ticket_transactions,
        ops.retail_revenue,
        ops.retail_discounts,
        ops.retail_items_sold,
        ops.retail_transactions,
        ops.total_revenue,
        ops.total_visitors
    FROM {{ ref('fct_daily_operations') }} ops
    INNER JOIN {{ ref('dim_date') }} dd ON ops.visit_date = dd.date_day
),

weekly_agg AS (
    SELECT
        year_num,
        week_of_year,
        fiscal_year,
        fiscal_quarter,
        MIN(visit_date) AS week_start_date,
        MAX(visit_date) AS week_end_date,
        COUNT(DISTINCT visit_date) AS operating_days,
        SUM(ticket_revenue) AS ticket_revenue_gross,
        SUM(ticket_discounts) AS ticket_discount_amount,
        SUM(ticket_revenue) - SUM(ticket_discounts) AS ticket_revenue_net,
        SUM(tickets_sold) AS tickets_sold,
        SUM(ticket_transactions) AS ticket_transactions,
        SUM(retail_revenue) AS retail_revenue_gross,
        SUM(retail_discounts) AS retail_discount_amount,
        SUM(retail_revenue) - SUM(retail_discounts) AS retail_revenue_net,
        SUM(retail_items_sold) AS retail_items_sold,
        SUM(retail_transactions) AS retail_transactions,
        SUM(total_revenue) AS total_revenue_gross,
        SUM(total_revenue) - SUM(ticket_discounts) - SUM(retail_discounts) AS total_revenue_net,
        SUM(total_visitors) AS total_visitors
    FROM daily_revenue
    GROUP BY year_num, week_of_year, fiscal_year, fiscal_quarter
),

weekly_with_comparisons AS (
    SELECT
        curr.*,

        -- YoY: same week number from prior year
        yoy.total_revenue_gross AS yoy_total_revenue_gross,
        yoy.total_revenue_net AS yoy_total_revenue_net,
        yoy.ticket_revenue_gross AS yoy_ticket_revenue_gross,
        yoy.ticket_revenue_net AS yoy_ticket_revenue_net,
        yoy.retail_revenue_gross AS yoy_retail_revenue_gross,
        yoy.retail_revenue_net AS yoy_retail_revenue_net,
        yoy.tickets_sold AS yoy_tickets_sold,
        yoy.ticket_transactions AS yoy_ticket_transactions,
        yoy.retail_items_sold AS yoy_retail_items_sold,
        yoy.retail_transactions AS yoy_retail_transactions,
        yoy.total_visitors AS yoy_total_visitors,

        -- Budget proxy: trailing 4-week average as plan
        AVG(curr.total_revenue_gross) OVER (
            ORDER BY curr.year_num, curr.week_of_year
            ROWS BETWEEN 4 PRECEDING AND 1 PRECEDING
        ) AS budget_total_revenue,
        AVG(curr.ticket_revenue_gross) OVER (
            ORDER BY curr.year_num, curr.week_of_year
            ROWS BETWEEN 4 PRECEDING AND 1 PRECEDING
        ) AS budget_ticket_revenue,
        AVG(curr.retail_revenue_gross) OVER (
            ORDER BY curr.year_num, curr.week_of_year
            ROWS BETWEEN 4 PRECEDING AND 1 PRECEDING
        ) AS budget_retail_revenue

    FROM weekly_agg curr
    LEFT JOIN weekly_agg yoy
        ON curr.week_of_year = yoy.week_of_year
        AND curr.year_num = yoy.year_num + 1
),

final AS (
    SELECT
        week_start_date,
        week_end_date,
        year_num,
        week_of_year,
        fiscal_year,
        fiscal_quarter,
        operating_days,

        -- Component breakdown
        ticket_revenue_gross,
        ticket_discount_amount,
        ticket_revenue_net,
        retail_revenue_gross,
        retail_discount_amount,
        retail_revenue_net,
        total_revenue_gross,
        total_revenue_net,
        tickets_sold,
        ticket_transactions,
        retail_items_sold,
        retail_transactions,
        total_visitors,

        -- Derived metrics
        DIV0(ticket_revenue_gross, NULLIF(ticket_transactions, 0)) AS ticket_aov,
        DIV0(retail_revenue_gross, NULLIF(retail_transactions, 0)) AS retail_aov,
        DIV0(total_revenue_gross, NULLIF(total_visitors, 0)) AS revenue_per_visitor,

        -- YoY bridge
        COALESCE(yoy_total_revenue_gross, 0) AS yoy_total_revenue_gross,
        total_revenue_gross - COALESCE(yoy_total_revenue_gross, 0) AS yoy_total_variance,
        ticket_revenue_gross - COALESCE(yoy_ticket_revenue_gross, 0) AS yoy_ticket_variance,
        retail_revenue_gross - COALESCE(yoy_retail_revenue_gross, 0) AS yoy_retail_variance,
        (ticket_discount_amount - COALESCE(yoy_ticket_revenue_gross - yoy_ticket_revenue_net, 0)) * -1 AS yoy_ticket_discount_impact,
        (retail_discount_amount - COALESCE(yoy_retail_revenue_gross - yoy_retail_revenue_net, 0)) * -1 AS yoy_retail_discount_impact,
        tickets_sold - COALESCE(yoy_tickets_sold, 0) AS yoy_ticket_volume_change,
        retail_items_sold - COALESCE(yoy_retail_items_sold, 0) AS yoy_retail_volume_change,
        total_visitors - COALESCE(yoy_total_visitors, 0) AS yoy_visitor_change,

        -- Budget vs actual bridge
        COALESCE(budget_total_revenue, 0) AS budget_total_revenue,
        total_revenue_gross - COALESCE(budget_total_revenue, 0) AS budget_total_variance,
        ticket_revenue_gross - COALESCE(budget_ticket_revenue, 0) AS budget_ticket_variance,
        retail_revenue_gross - COALESCE(budget_retail_revenue, 0) AS budget_retail_variance,
        CASE WHEN COALESCE(budget_total_revenue, 0) > 0
            THEN ROUND((total_revenue_gross - budget_total_revenue) / budget_total_revenue * 100, 2)
            ELSE NULL
        END AS budget_variance_pct,

        -- Week-over-week change (prior week)
        LAG(total_revenue_gross) OVER (ORDER BY year_num, week_of_year) AS prior_week_total_revenue,
        total_revenue_gross - LAG(total_revenue_gross) OVER (ORDER BY year_num, week_of_year) AS wow_total_variance,
        ticket_revenue_gross - LAG(ticket_revenue_gross) OVER (ORDER BY year_num, week_of_year) AS wow_ticket_variance,
        retail_revenue_gross - LAG(retail_revenue_gross) OVER (ORDER BY year_num, week_of_year) AS wow_retail_variance

    FROM weekly_with_comparisons
)

SELECT * FROM final
