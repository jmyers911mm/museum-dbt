# Silver Models

Cleaned, validated, and enriched data models that apply business rules, deduplication, and type enforcement. Materialized as **incremental tables** in the `SILVER` schema using merge strategy.

## Responsibilities

- Apply data quality rules and validation
- Deduplicate records
- Enrich with derived business columns (e.g., `is_discounted`, `campaign_category`)
- Enforce schema contracts where applicable
- Serve as the trusted foundation for Gold layer consumption

## Models

| Model | Description |
|-------|-------------|
| `silver_pos_tickets` | Cleaned ticket transactions with derived pricing fields |
| `silver_pos_retail` | Cleaned retail transactions with product enrichment |
| `silver_ticket_scans` | Validated scan events with gate and result classification |
| `silver_sf_crm` | Deduplicated CRM contacts with membership attributes |
| `silver_sf_marketing_cloud` | Email campaign events with subscriber resolution |
| `silver_google_analytics` | Session-level web data with channel classification |
| `silver_google_ads` | Google Ads performance with cost conversion and campaign categorization |
| `silver_meta_ads` | Meta Ads performance with campaign categorization |
| `silver_ticket_inventory` | Ticket capacity by date/window/type |

## Conventions

- File naming: `silver_<source_system>.sql`
- Incremental strategy: `merge` with `on_schema_change: append_new_columns`
- All models tagged `['daily', 'critical']`
- Schema tests defined in `schema.yml`
