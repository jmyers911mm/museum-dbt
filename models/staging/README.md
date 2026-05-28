# Staging Models

Thin transformations directly on top of raw Bronze source tables. These models are materialized as **views** in the `SILVER` schema and serve as the single entry point for raw data into the dbt DAG.

## Responsibilities

- Rename and cast columns to consistent types
- Apply light filtering (e.g., remove test/null records)
- Standardize timestamps to `TIMESTAMP_NTZ`
- Derive computed columns that are universally needed downstream (e.g., `transaction_date` from timestamp)
- No joins, no aggregations, no business logic

## Source Systems

| Model | Source Table | System |
|-------|-------------|--------|
| `stg_pos_tickets` | `raw_pos_tickets` | Museum POS (ticketing) |
| `stg_pos_retail` | `raw_pos_retail` | Museum POS (gift shop) |
| `stg_ticket_scans` | `raw_ticket_scans` | Gate scanning system |
| `stg_sf_crm` | `raw_sf_crm` | Salesforce CRM |
| `stg_sf_marketing_cloud` | `raw_sf_marketing_cloud` | Salesforce Marketing Cloud |
| `stg_google_analytics` | `raw_google_analytics` | Google Analytics 4 |
| `stg_google_ads` | `raw_google_ads` | Google Ads |
| `stg_meta_ads` | `raw_meta_ads` | Meta Ads (Facebook/Instagram) |
| `stg_ticket_capacity` | `raw_ticket_capacity` | Ticket inventory config |

## Conventions

- File naming: `stg_<source_system>.sql`
- All source definitions live in `sources.yml`
- Freshness checks enforced at source level (30-min for POS, 24-hr for marketing)
