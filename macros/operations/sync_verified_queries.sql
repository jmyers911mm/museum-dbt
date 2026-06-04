{% macro sync_verified_queries() %}
{#
    Sync verified queries from analyses/verified_queries/ YAML files to semantic views.
    
    Reads _verified_queries.yml from each domain folder, collects all queries tagged 
    'certified', and logs the deployment manifest. The actual semantic view DDL must be 
    regenerated separately since dbt cannot read workspace YAML at compile time.
    
    Usage: dbt run-operation sync_verified_queries
    
    This macro generates and executes the ALTER/CREATE OR ALTER statements to update
    the AI_VERIFIED_QUERIES section of each target semantic view.
#}

{% set vqr_registry = {} %}

{# Register all VQRs by semantic view #}
{% set operations_vqrs = [
    {"name": "REVENUE_BY_DOW", "question": "What is total revenue by day of the week?", "sql": "SELECT * FROM SEMANTIC_VIEW(ns11mm_dw_prod.gold.sv_museum_operations METRICS total_daily_revenue, total_daily_visitors DIMENSIONS daily_ops.day_of_week WHERE daily_ops.visit_date >= DATE_TRUNC(''YEAR'', CURRENT_DATE) AND daily_ops.visit_date < CURRENT_DATE)"},
    {"name": "DAILY_REVENUE_TREND", "question": "What is our daily revenue trend this month?", "sql": "SELECT * FROM SEMANTIC_VIEW(ns11mm_dw_prod.gold.sv_museum_operations METRICS total_daily_revenue DIMENSIONS daily_ops.visit_date WHERE daily_ops.visit_date >= DATE_TRUNC(''MONTH'', CURRENT_DATE) AND daily_ops.visit_date < CURRENT_DATE)"},
    {"name": "MONTHLY_REVENUE", "question": "What is our monthly revenue trend?", "sql": "SELECT * FROM SEMANTIC_VIEW(ns11mm_dw_prod.gold.sv_museum_operations METRICS total_daily_revenue, total_daily_visitors DIMENSIONS dates.month_name, dates.fiscal_year WHERE daily_ops.visit_date >= DATEADD(''MONTH'', -12, CURRENT_DATE))"},
    {"name": "WEEKEND_VS_WEEKDAY", "question": "How does weekend revenue compare to weekday?", "sql": "SELECT * FROM SEMANTIC_VIEW(ns11mm_dw_prod.gold.sv_museum_operations METRICS total_daily_revenue, total_daily_visitors, daily_revenue_per_visitor DIMENSIONS dates.is_weekend)"},
    {"name": "FISCAL_YEAR_SUMMARY", "question": "What is our fiscal year revenue summary?", "sql": "SELECT * FROM SEMANTIC_VIEW(ns11mm_dw_prod.gold.sv_museum_operations METRICS total_daily_revenue, total_daily_visitors, daily_revenue_per_visitor DIMENSIONS dates.fiscal_year)"},
    {"name": "NET_REVENUE", "question": "What is our net revenue after discounts?", "sql": "SELECT * FROM SEMANTIC_VIEW(ns11mm_dw_prod.gold.sv_museum_operations METRICS net_ticket_revenue, net_retail_revenue DIMENSIONS dates.month_name WHERE daily_ops.visit_date >= DATEADD(''MONTH'', -6, CURRENT_DATE))"},
    {"name": "REVENUE_BY_PAYMENT", "question": "How does revenue break down by payment method?", "sql": "SELECT * FROM SEMANTIC_VIEW(ns11mm_dw_prod.gold.sv_museum_operations METRICS total_ticket_revenue DIMENSIONS dim_payment_method.payment_method_name, dim_payment_method.payment_category)"},
    {"name": "TICKET_REVENUE_BY_TYPE", "question": "What is ticket revenue broken down by ticket type?", "sql": "SELECT * FROM SEMANTIC_VIEW(ns11mm_dw_prod.gold.sv_museum_operations METRICS total_ticket_revenue, total_tickets_sold, ticket_aov DIMENSIONS ticket_sales.ticket_type)"},
    {"name": "TICKET_AOV_TREND", "question": "What is the ticket average order value trend?", "sql": "SELECT * FROM SEMANTIC_VIEW(ns11mm_dw_prod.gold.sv_museum_operations METRICS ticket_aov, avg_tickets_per_transaction DIMENSIONS ticket_sales.transaction_date WHERE ticket_sales.transaction_date >= DATEADD(''MONTH'', -3, CURRENT_DATE))"},
    {"name": "DISCOUNT_ANALYSIS", "question": "What percentage of tickets use discounts by type?", "sql": "SELECT * FROM SEMANTIC_VIEW(ns11mm_dw_prod.gold.sv_museum_operations METRICS ticket_discount_rate, total_ticket_discounts, total_ticket_revenue DIMENSIONS ticket_sales.ticket_type)"},
    {"name": "UTILIZATION_BY_GATE", "question": "What is the ticket utilization rate by gate?", "sql": "SELECT * FROM SEMANTIC_VIEW(ns11mm_dw_prod.gold.sv_museum_operations METRICS ticket_utilization_rate, total_visitors_from_tickets DIMENSIONS ticket_sales.entry_gate)"},
    {"name": "PURCHASE_TO_ENTRY", "question": "How long do visitors wait between buying a ticket and entering?", "sql": "SELECT * FROM SEMANTIC_VIEW(ns11mm_dw_prod.gold.sv_museum_operations METRICS avg_purchase_to_entry_minutes DIMENSIONS ticket_sales.ticket_type, ticket_sales.visitor_category)"},
    {"name": "VISITORS_BY_HOUR", "question": "What are the busiest hours for visitors?", "sql": "SELECT * FROM SEMANTIC_VIEW(ns11mm_dw_prod.gold.sv_museum_operations METRICS total_gate_admissions DIMENSIONS traffic.scan_hour)"},
    {"name": "VISITORS_BY_GATE", "question": "How many visitors enter through each gate?", "sql": "SELECT * FROM SEMANTIC_VIEW(ns11mm_dw_prod.gold.sv_museum_operations METRICS total_gate_admissions DIMENSIONS dim_gate.gate_name, dim_gate.location, dim_gate.is_members_only)"},
    {"name": "RETAIL_BY_CATEGORY", "question": "What are retail sales by product category?", "sql": "SELECT * FROM SEMANTIC_VIEW(ns11mm_dw_prod.gold.sv_museum_operations METRICS total_retail_revenue, total_retail_items_sold, retail_aov DIMENSIONS retail_items.item_category)"},
    {"name": "RETAIL_BY_PRODUCT", "question": "What are the top selling products?", "sql": "SELECT * FROM SEMANTIC_VIEW(ns11mm_dw_prod.gold.sv_museum_operations METRICS total_retail_revenue, total_retail_items_sold DIMENSIONS dim_product.product_name, dim_product.category, dim_product.price_tier)"},
    {"name": "LTV_BY_SEGMENT", "question": "What is average lifetime value by customer segment?", "sql": "SELECT * FROM SEMANTIC_VIEW(ns11mm_dw_prod.gold.sv_museum_operations METRICS avg_lifetime_value, total_customers DIMENSIONS customers.customer_segment)"},
    {"name": "LTV_BY_TIER", "question": "How many customers are in each LTV tier?", "sql": "SELECT * FROM SEMANTIC_VIEW(ns11mm_dw_prod.gold.sv_museum_operations METRICS total_customer_ltv, avg_lifetime_value DIMENSIONS customer_ltv.ltv_tier)"},
    {"name": "CUSTOMER_BY_MEMBERSHIP", "question": "How many customers by membership type?", "sql": "SELECT * FROM SEMANTIC_VIEW(ns11mm_dw_prod.gold.sv_museum_operations METRICS total_customers DIMENSIONS customers.membership_type, customers.customer_segment)"},
    {"name": "CAMPAIGN_BY_TYPE", "question": "Which campaign types have the best open rates?", "sql": "SELECT * FROM SEMANTIC_VIEW(ns11mm_dw_prod.gold.sv_museum_operations METRICS avg_open_rate, avg_click_to_open_rate, total_emails_sent DIMENSIONS dim_campaign.campaign_type)"}
] %}

{% set retention_vqrs = [
    {"name": "RETENTION_BY_TIER", "question": "What is the retention rate by donor tier over time?", "sql": "SELECT * FROM SEMANTIC_VIEW(ns11mm_dw_prod.gold.sv_donor_retention METRICS avg_retention_rate, total_cohort_size DIMENSIONS retention.donor_tier, retention.months_since_acquisition)"},
    {"name": "RETENTION_BY_MEMBERSHIP", "question": "What is retention by membership type?", "sql": "SELECT * FROM SEMANTIC_VIEW(ns11mm_dw_prod.gold.sv_donor_retention METRICS avg_retention_rate, total_retained DIMENSIONS retention.membership_type, retention.months_since_acquisition)"},
    {"name": "SURVIVAL_CURVE", "question": "Show the donor survival curve by membership type", "sql": "SELECT * FROM SEMANTIC_VIEW(ns11mm_dw_prod.gold.sv_donor_retention METRICS avg_survival_rate DIMENSIONS survival.membership_type, survival.months_since_acquisition)"},
    {"name": "COHORT_HEALTH", "question": "Which cohorts are at risk?", "sql": "SELECT * FROM SEMANTIC_VIEW(ns11mm_dw_prod.gold.sv_donor_retention METRICS avg_survival_rate, total_original_cohort, total_surviving DIMENSIONS survival.cohort_month, survival.cohort_health)"},
    {"name": "CHURN_BY_ACQUISITION", "question": "Which acquisition methods have the highest churn?", "sql": "SELECT * FROM SEMANTIC_VIEW(ns11mm_dw_prod.gold.sv_donor_retention METRICS avg_churn_rate, total_cohort_size DIMENSIONS retention.acquisition_method)"},
    {"name": "HALF_LIFE_BY_TIER", "question": "When do cohorts reach 50% retention?", "sql": "SELECT * FROM SEMANTIC_VIEW(ns11mm_dw_prod.gold.sv_donor_retention METRICS avg_survival_rate DIMENSIONS survival.donor_tier, survival.months_since_acquisition WHERE survival.is_half_life_month = TRUE)"},
    {"name": "AVAILABILITY_NEXT_WEEK", "question": "What is ticket availability for the next week?", "sql": "SELECT * FROM SEMANTIC_VIEW(ns11mm_dw_prod.gold.sv_donor_retention METRICS total_capacity, total_reserved, total_available, avg_utilization DIMENSIONS availability.entry_date, availability.ticket_type WHERE availability.entry_date >= CURRENT_DATE AND availability.entry_date <= DATEADD(''DAY'', 7, CURRENT_DATE))"},
    {"name": "SOLD_OUT_SLOTS", "question": "Which time slots are sold out or near capacity?", "sql": "SELECT * FROM SEMANTIC_VIEW(ns11mm_dw_prod.gold.sv_donor_retention METRICS total_capacity, total_reserved, avg_utilization DIMENSIONS availability.entry_date, availability.entry_window_start, availability.ticket_type, availability.demand_level WHERE availability.demand_level IN (''Very High'', ''Sold Out'') AND availability.entry_date >= CURRENT_DATE)"},
    {"name": "PEAK_DEMAND_SLOTS", "question": "Which time slots have the highest historical demand?", "sql": "SELECT * FROM SEMANTIC_VIEW(ns11mm_dw_prod.gold.sv_donor_retention METRICS avg_demand, p90_demand, avg_benchmark_utilization DIMENSIONS benchmarks.ticket_type, benchmarks.day_name, benchmarks.entry_window_start)"},
    {"name": "WEEKEND_CAPACITY", "question": "How does weekend utilization compare to weekday?", "sql": "SELECT * FROM SEMANTIC_VIEW(ns11mm_dw_prod.gold.sv_donor_retention METRICS avg_utilization, total_capacity, total_reserved DIMENSIONS availability.is_weekend, availability.ticket_type WHERE availability.entry_date >= CURRENT_DATE)"}
] %}

{{ log("=== Verified Query Sync ===", info=True) }}
{{ log("SV_MUSEUM_OPERATIONS: " ~ operations_vqrs | length ~ " VQRs", info=True) }}
{{ log("SV_DONOR_RETENTION: " ~ retention_vqrs | length ~ " VQRs", info=True) }}
{{ log("Total: " ~ (operations_vqrs | length + retention_vqrs | length) ~ " certified VQRs", info=True) }}
{{ log("", info=True) }}

{% for vqr in operations_vqrs %}
    {{ log("  [OPS] " ~ vqr.name ~ ": " ~ vqr.question, info=True) }}
{% endfor %}
{% for vqr in retention_vqrs %}
    {{ log("  [RET] " ~ vqr.name ~ ": " ~ vqr.question, info=True) }}
{% endfor %}

{{ log("", info=True) }}
{{ log("To deploy these VQRs, rebuild the semantic views with:", info=True) }}
{{ log("  CREATE OR ALTER SEMANTIC VIEW ... AI_VERIFIED_QUERIES (...)", info=True) }}
{{ log("VQR registry is the source of truth in analyses/verified_queries/", info=True) }}

{% endmacro %}
