# Gold Models

Business-ready dimensional models organized into dimensions, facts, and reports. Materialized in the `GOLD` schema with grants to `POWERBI_ROLE` and `ML_ROLE`.

## Structure

```
gold/
├── dimensions/    # Conformed dimensions (Type 2 where applicable)
├── facts/         # Fact tables at defined grains
└── reports/       # Pre-joined report models for BI consumption
```

## Dimensions

| Model | Description |
|-------|-------------|
| `dim_date` | Date spine with fiscal year (July start), weekday, quarter |
| `dim_customer` | Identity-resolved customer master from CRM + POS matching |
| `dim_ticket_type` | Ticket type reference |
| `dim_gate` | Physical gate reference |
| `dim_payment_method` | Payment method reference |
| `dim_product` | Retail product catalog |
| `dim_marketing_channel` | Marketing channel classification |
| `dim_campaign` | Campaign reference with type and tier |
| `dim_member` | Membership-focused customer view |

## Facts

| Model | Grain | Description |
|-------|-------|-------------|
| `fct_ticket_sales` | Ticket barcode | Ticket-level sales with scan outcomes and identity resolution |
| `fct_retail_line_items` | Line item | Retail transactions with product/customer FKs |
| `fct_daily_operations` | Day | Daily aggregate of visitors, tickets, retail |
| `fct_monthly_operations` | Month | Monthly operational rollup |
| `fct_monthly_retail` | Month × category | Monthly retail rollups with avg daily revenue |
| `fct_visitor_traffic` | Date × hour × gate | Hourly gate traffic with valid/rejected scans |
| `fct_retail_performance` | Date × category | Daily retail by category (deprecated 2026-07-01) |
| `fct_ticket_utilization` | Ticket | Per-ticket scan outcomes (deprecated 2026-07-01) |
| `fct_ticket_availability` | Capacity slot | Utilization %, demand level, remaining capacity |
| `fct_ticket_demand_benchmarks` | Benchmark | 90-day rolling stats with ±2σ bounds |
| `fct_campaign_performance` | Campaign | Email campaign lifetime open/click/bounce rates |
| `fct_member_360` | Contact | Unified tickets + retail + donations + email engagement |
| `fct_donor_retention` | Cohort × month × segment | Retention and churn rates by cohort |
| `fct_donor_cohort_survival` | Cohort × period | Survival analysis with half-life detection |
| `fct_digital_ad_performance` | Campaign × adgroup × date × platform | Unified Google Ads + Meta Ads metrics |
| `fct_website_traffic` | Date × channel × source × page × device | GA sessions and conversions |
| `fct_ad_campaign_daily` | Campaign × platform × date | Campaign-level daily summary |
| `fct_marketing_channel_summary` | Date × channel | Unified cross-channel performance |
| `fct_website_funnel` | Date × channel × device | Conversion funnel with drop-off rates |
| `fct_marketing_sales_daily` | Date × channel | Marketing spend joined with ticket/retail revenue |
| `fct_campaign_attribution` | Date × channel × source × medium × segment | Session-attributed revenue |
| `bridge_session_customer` | Session × customer | Links converting GA sessions to customers |

## Reports

| Model | Description |
|-------|-------------|
| `rpt_daily_operations` | Daily ops with fiscal context and KPIs |
| `rpt_ticket_sales` | Star-schema ticket report with all dimension attributes |
| `rpt_retail_performance` | Retail report with product, payment, and customer attributes |
| `rpt_visitor_traffic` | Hourly gate traffic with utilization metrics |
| `rpt_campaign_performance` | Campaign metrics with type/tier classification |
| `rpt_digital_marketing` | Combined ad performance and website traffic |
| `rpt_member_360` | Identity-resolved member profile with LTV |
| `rpt_customer_ltv` | Unified LTV report with tier classification |

## Conventions

- Dimensions: materialized as `table`, group `gold_dimensions`
- Facts: materialized as `incremental` (merge), group `gold_facts`
- Reports: materialized as `incremental` (merge), group `gold_reports`
- All models have `public` access and post-hook grants
