# museum-dbt

A production dbt project for the Museum Data Warehouse on Snowflake. Transforms raw bronze-layer data into analytics-ready silver, gold, and ML feature tables powering operations dashboards, member engagement, retail performance, and ticket demand forecasting.

**Current state:** 40 models | 6 sources | 252+ tests | 1 snapshot | 3 macros

---

## Table of Contents

- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Data Sources](#data-sources)
- [Data Layers](#data-layers)
- [Models](#models)
  - [Staging](#staging-6-models)
  - [Silver](#silver-6-models)
  - [Gold Dimensions](#gold-dimensions-7-models)
  - [Gold Facts](#gold-facts-12-models)
  - [Gold Reports](#gold-reports-5-models)
  - [ML Features](#ml-features-4-models)
- [Testing Strategy](#testing-strategy)
  - [Schema Tests](#schema-tests)
  - [Data Quality Tests](#data-quality-tests)
  - [Business Rule Tests](#business-rule-tests)
  - [Reconciliation Tests](#reconciliation-tests)
  - [Referential Integrity Tests](#referential-integrity-tests)
- [Macros](#macros)
- [Snapshots](#snapshots)
- [Incremental Strategy](#incremental-strategy)
- [Access Control & Grants](#access-control--grants)
- [Environments](#environments)
- [CI/CD Pipeline](#cicd-pipeline)
- [Getting Started](#getting-started)
- [Common Operations](#common-operations)
- [Deployment](#deployment)
- [Governance](#governance)
- [Contributing](#contributing)

---

## Architecture

```
┌──────────────────────────────────────────────────────────────────────────┐
│                        MUSEUM DATA WAREHOUSE                             │
├──────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  BRONZE (raw)  →  STAGING (views)  →  SILVER (incremental)              │
│       │                                      │                           │
│       │                                      ▼                           │
│       │                              GOLD (incremental)                  │
│       │                          ┌────────┬────────┬────────┐           │
│       │                          │  Dims  │ Facts  │Reports │           │
│       │                          └────────┴────────┴────────┘           │
│       │                                      │                           │
│       │                                      ▼                           │
│       │                            ML_FEATURES (tables)                  │
│       │                                      │                           │
│       ▼                                      ▼                           │
│  Snowflake ML FORECAST          Power BI / Snowsight Dashboards         │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘
```

### Key Design Decisions

- **Incremental merge strategy** for Silver and Gold layers to minimize reprocessing
- **Hashdiff columns** on all staging models for change detection
- **Contract enforcement** on dimension tables to catch schema drift
- **Fiscal year logic** uses July start (museum fiscal calendar)
- **Transient tables** for Silver and ML Features (no Time Travel overhead)
- **Copy grants** enabled for Silver and Gold (preserves downstream access)

---

## Project Structure

```
museum-dbt/
├── dbt_project.yml            # Project configuration, materializations, hooks
├── profiles.yml               # Connection profiles (dev, staging, prod)
├── CHANGELOG.md               # Release history
├── CONTRIBUTING.md            # Development workflow & conventions
├── CODEOWNERS                 # PR approval routing
├── .github/
│   └── workflows/
│       └── dbt-ci.yml         # Slim CI pipeline
├── models/
│   ├── staging/               # Views over bronze sources (6 models)
│   │   ├── sources.yml        # Source definitions + freshness + tests
│   │   └── stg_*.sql
│   ├── silver/                # Incremental cleansed models (6 models)
│   │   ├── schema.yml         # Column tests, data quality generics
│   │   └── silver_*.sql
│   ├── gold/
│   │   ├── dimensions/        # Dimension tables (7 models)
│   │   │   ├── schema.yml     # Contract enforcement, accepted_values
│   │   │   └── dim_*.sql
│   │   ├── facts/             # Fact tables (12 models)
│   │   │   └── fct_*.sql
│   │   └── reports/           # Pre-joined dashboard views (5 models)
│   │       └── rpt_*.sql
│   └── ml_features/           # ML feature tables (4 models)
│       └── ml_*.sql
├── macros/
│   ├── generic_tests/         # Custom test macros
│   │   └── test_hashdiff_integrity.sql
│   └── operations/            # Run-operation macros
│       ├── generate_schema_name.sql
│       └── create_ticket_demand_forecast.sql
├── tests/
│   ├── business_rules/        # Rate bounds, no-negative checks (4 tests)
│   ├── reconciliation/        # Cross-layer count/revenue matching (6 tests)
│   └── referential_integrity/ # FK existence checks (8 tests)
├── snapshots/
│   └── snap_sf_crm.sql        # SCD Type 2 for CRM contacts
└── terraform/                 # Snowflake infrastructure (warehouses, roles, etc.)
    ├── main.tf
    ├── modules/
    ├── environments/
    └── pipelines/
```

---

## Data Sources

Defined in `models/staging/sources.yml`:

| Source | Table | Description |
|--------|-------|-------------|
| bronze | `raw_pos_tickets` | POS ticket sales (574+ rows) |
| bronze | `raw_pos_retail` | Gift shop/retail transactions |
| bronze | `raw_sf_crm` | Salesforce CRM contacts |
| bronze | `raw_sf_marketing_cloud` | Email campaign events |
| bronze | `raw_ticket_scans` | Gate entry scan logs |
| bronze | `raw_ticket_capacity` | Capacity by date/window/type (19,200 rows) |

All sources have:
- `not_null` and `unique` tests on primary keys
- `accepted_values` tests on type/category columns
- Column-level descriptions

---

## Data Layers

| Layer | Schema | Materialization | Strategy | Tags | Description |
|-------|--------|-----------------|----------|------|-------------|
| Staging | SILVER | View | — | daily, critical | Type casting, trimming, hashdiff computation |
| Silver | SILVER | Incremental | Merge | daily, critical | Business logic, computed columns, deduplication |
| Gold | GOLD | Incremental | Merge | daily, critical | Star schema: dimensions + facts + reports |
| ML Features | ML_FEATURES | Table | Full rebuild | daily, non-critical | Feature-engineered tables for ML models |

### on-run-start Hooks
- Source freshness check
- Circuit breaker (skippable via `--vars 'skip_circuit_breaker: true'`)

### on-run-end Hooks
- Audit log entry to `SILVER.DBT_RUN_AUDIT_LOG`

---

## Models

### Staging (6 models)

| Model | Source | Key Transformations |
|-------|--------|---------------------|
| `stg_pos_tickets` | raw_pos_tickets | Trim, lowercase email, hashdiff, entry window mapping |
| `stg_pos_retail` | raw_pos_retail | Trim item names, lowercase email, hashdiff |
| `stg_sf_crm` | raw_sf_crm | Trim names, lowercase email, hashdiff |
| `stg_sf_marketing_cloud` | raw_sf_marketing_cloud | Trim campaign names, lowercase email, hashdiff |
| `stg_ticket_scans` | raw_ticket_scans | Hashdiff on scan attributes |
| `stg_ticket_capacity` | raw_ticket_capacity | Passthrough with hashdiff |

### Silver (6 models)

| Model | Key Logic |
|-------|-----------|
| `silver_pos_tickets` | Visitor category derivation (Adult/Child/Senior/Member/School Group/Family), discount flag |
| `silver_pos_retail` | Discount percentage calculation, is_discounted flag |
| `silver_sf_crm` | Computed membership status (Active/Grace Period/Expired/Lapsed), donor tier (Major/Mid-Level/Donor/Small/Non-Donor), days_since_last_visit |
| `silver_sf_marketing_cloud` | Event date extraction, is_bounced/is_unsubscribed flags |
| `silver_ticket_scans` | scan_date/scan_hour extraction, is_valid_scan derivation |
| `silver_ticket_inventory` | Capacity vs reservations join, utilization %, demand level classification |

### Gold Dimensions (7 models)

| Model | Grain | Key Attributes |
|-------|-------|----------------|
| `dim_date` | 1 row per day (2025-2027) | Fiscal year/quarter (July start), is_weekend, is_today, days_ago |
| `dim_campaign` | 1 row per campaign | Campaign type (Membership/Fundraising/Newsletter/Retail/Exhibition), audience size tier |
| `dim_gate` | 1 row per gate | Gate name, location, is_members_only, is_primary_entrance |
| `dim_member` | 1 row per contact | Full profile: membership status, donor tier, contact preferences |
| `dim_payment_method` | 1 row per method | Payment category (Card/Cash/Digital), is_electronic |
| `dim_product` | 1 row per SKU | Category, price tier (Premium/Mid-Range/Value), product group |
| `dim_ticket_type` | 1 row per ticket type | Visitor category, pricing tier, is_free_admission, is_special_exhibition |

### Gold Facts (12 models)

| Model | Grain | Key Metrics |
|-------|-------|-------------|
| `fct_daily_operations` | 1 row per day | total_visitors, ticket/retail revenue, discounts, scans, gates_active |
| `fct_monthly_operations` | 1 row per fiscal month | Monthly aggregations, revenue_per_visitor, peak_day_visitors |
| `fct_visitor_traffic` | 1 row per date+hour+gate | visitors_admitted, valid/rejected scans, valid_scan_rate_pct |
| `fct_retail_performance` | 1 row per date+category | transaction_count, items_sold, gross/net revenue, discount_rate_pct |
| `fct_monthly_retail` | 1 row per month+category | Monthly retail rollups, avg_daily_revenue, avg_items_per_transaction |
| `fct_ticket_utilization` | 1 row per ticket | was_scanned, visitors_admitted, utilization_status (Used/Unused/Rejected) |
| `fct_ticket_availability` | 1 row per capacity slot | Utilization %, demand level, remaining capacity |
| `fct_ticket_demand_benchmarks` | 1 row per benchmark | 90-day rolling avg/median/p25/p75/p90 with ±2σ bounds |
| `fct_campaign_performance` | 1 row per campaign | open/click/bounce/unsubscribe rates, unique recipients |
| `fct_member_360` | 1 row per contact | Unified view: tickets + retail + donations + email engagement |
| `fct_donor_retention` | 1 row per cohort+month | retention_rate_pct, churn_rate_pct by cohort month |
| `fct_donor_cohort_survival` | 1 row per cohort+period | Survival analysis with cohort sizing |

### Gold Reports (5 models)

Pre-joined views optimized for dashboard consumption (joins facts to dim_date):

- `rpt_daily_operations` — Operations: revenue, visitors, scans with day/fiscal context
- `rpt_visitor_traffic` — Traffic: hourly gate patterns with weekend flag
- `rpt_retail_performance` — Retail: category performance with fiscal context
- `rpt_campaign_performance` — Campaign: email metrics passthrough
- `rpt_member_360` — Members: full 360 view passthrough

### ML Features (4 models)

| Model | Target Use Case | Key Features |
|-------|-----------------|--------------|
| `ml_daily_visitor_features` | Visitor forecasting | 7/30-day rolling avgs, peak hour, day-of-week, same-day-last-week lag |
| `ml_ticket_demand_features` | Ticket demand prediction | Demand level encoding, rolling utilization, z-scores |
| `ml_donor_churn_features` | Donor churn prediction | tenure_months, donation_velocity, recency_band, is_churned label |
| `ml_member_churn_features` | Member churn risk | days_since_last_interaction, email_click_through_rate, churn_risk_flag |

---

## Testing Strategy

### Schema Tests (~250)

Applied via `schema.yml` files at each layer:
- `not_null` / `unique` on all primary keys
- `accepted_values` on categorical columns (ticket types, membership statuses, donor tiers)
- Custom generics: `hashdiff_integrity`, `late_arriving_data`, `daily_volume_bounds`, `cardinality_change`, `distribution_shift`, `z_score_outlier`, `positive_value`, `value_between`, `null_rate_threshold`

### Data Quality Tests

| Test Macro | Purpose | Severity |
|------------|---------|----------|
| `hashdiff_integrity` | Detects hash collisions vs true duplicates | warn on retail/marketing |
| `late_arriving_data` | Alerts if data > 72h old arrives | warn |
| `daily_volume_bounds` | Flags days with too few/many rows | error |
| `cardinality_change` | Detects unexpected new categories | error |
| `distribution_shift` | Identifies statistical distribution changes | warn |
| `z_score_outlier` | Flags values > 3σ from mean | warn |

### Business Rule Tests (4)

| Test | Validates |
|------|-----------|
| `assert_gold_campaign_rates_valid` | No rate > 100% (open, bounce, unsub, CTO) |
| `assert_gold_daily_ops_no_negative_revenue` | total_revenue >= 0 |
| `assert_gold_member_no_negative_ltv` | total_lifetime_value >= 0 |
| `assert_gold_ops_covers_all_scan_dates` | Daily ops has rows for every scan date |

### Reconciliation Tests (6)

| Test | Validates |
|------|-----------|
| `assert_silver_bronze_retail_count_match` | Silver row count = Bronze row count |
| `assert_silver_bronze_ticket_count_match` | Silver row count = Bronze row count |
| `assert_silver_bronze_scan_count_match` | Silver row count = Bronze row count |
| `assert_retail_revenue_reconciles` | Silver retail total ≈ Gold daily ops retail (±$10) |
| `assert_ticket_revenue_reconciles` | Silver ticket total ≈ Gold daily ops tickets (±$1) |
| `assert_visitor_count_reconciles` | Silver valid scans = Gold total_visitors (exact) |

### Referential Integrity Tests (8)

| Test | Validates |
|------|-----------|
| `assert_campaign_fk_integrity` | All fact campaign_ids exist in dim_campaign |
| `assert_gold_daily_ops_no_orphan_dates` | All ops dates have corresponding silver data |
| `assert_member360_emails_exist_in_crm` | All gold emails exist in silver CRM |
| `assert_member360_no_orphan_contacts` | All gold contacts exist in silver CRM |
| `assert_payment_methods_exist_in_dim` | All ticket payment methods are in dim |
| `assert_products_exist_in_dim` | All retail SKUs are in dim_product |
| `assert_scan_gates_exist_in_dim` | All scan gate_ids are in dim_gate |
| `assert_ticket_types_exist_in_dim` | All ticket types are in dim_ticket_type |

---

## Macros

### `generate_schema_name`
Custom schema routing that uses the schema defined in model config rather than appending to the target schema.

### `test_hashdiff_integrity`
Generic test that validates hashdiff columns by checking for:
1. Duplicate primary keys with different hashdiffs (true changes — expected)
2. Different primary keys with identical hashdiffs (hash collisions — flagged)

### `create_ticket_demand_forecast`
Run-operation macro that creates a Snowflake ML FORECAST model:
- Uses `fct_ticket_demand_benchmarks` as training data
- Multi-series forecasting by day-of-week + entry window + ticket type
- 90-day forecast horizon

```bash
dbt run-operation create_ticket_demand_forecast
```

---

## Snapshots

### `snap_sf_crm`
- **Strategy:** Check (on `hashdiff` column)
- **Unique key:** `contact_id`
- **Target schema:** SILVER
- **Purpose:** Track SCD Type 2 changes to CRM contacts (membership status changes, donation updates, etc.)

---

## Incremental Strategy

All incremental models use **merge** strategy:

| Layer | Unique Key Pattern | Merge Behavior |
|-------|-------------------|----------------|
| Silver | Source primary key (e.g., `transaction_id`) | Update existing, insert new |
| Gold Facts | Composite keys (e.g., `visit_date`, `date+category`) | Update existing, insert new |
| Gold Dims | Dimension key (e.g., `gate_id`, `product_id`) | Full rebuild (no incremental) |

**Schema change policy:** `append_new_columns` (new source columns are added automatically)

---

## Access Control & Grants

Configured via `dbt_project.yml` post-hooks:

| Layer | Grants |
|-------|--------|
| Gold (all) | `GRANT SELECT ON {{ this }} TO ROLE POWERBI_ROLE` |
| Gold (all) | `GRANT SELECT ON {{ this }} TO ROLE ML_ROLE` |
| ML Features | `GRANT SELECT ON {{ this }} TO ROLE ML_ROLE` |

Additional:
- `+copy_grants: true` on Silver and Gold ensures grants survive incremental rebuilds
- `+persist_docs: relation: true, columns: true` pushes descriptions to Snowflake metadata

---

## Environments

| Target | Database | Warehouse | Role | Threads |
|--------|----------|-----------|------|---------|
| dev | MUSEUM_DW_DEV | DBT_DEV_WH | DBT_DEV_ROLE | 4 |
| staging | MUSEUM_DW_STAGING | DBT_PROD_WH | DBT_PROD_ROLE | 8 |
| prod | MUSEUM_DW_PROD | DBT_PROD_WH | DBT_PROD_ROLE | 8 |

### Session Configuration
- `STATEMENT_TIMEOUT_IN_SECONDS = 3600` (default)
- `STATEMENT_TIMEOUT_IN_SECONDS = 300` (models tagged `intraday`)

---

## CI/CD Pipeline

### GitHub Actions (`.github/workflows/dbt-ci.yml`)

Triggers on PRs to `main` that touch model/macro/test files.

**Pipeline steps:**
1. Checkout PR branch + main branch (for state comparison)
2. Install dbt + dependencies
3. `dbt build --select state:modified+` — only builds/tests changed models and their downstream dependents
4. Fail the PR if any test errors occur

### Slim CI
Uses dbt state artifacts from `main` branch to identify modified models. Only changed models (and their children) are built and tested, keeping CI fast.

---

## Getting Started

### Prerequisites
- Snowflake account with `DBT_DEV_ROLE` access
- dbt installed (or use Snowsight Workspace)

### Commands

```bash
# Install packages
dbt deps

# Run all models (dev target)
dbt build

# Run specific layer
dbt run --select staging+
dbt run --select tag:daily
dbt run --select gold.facts

# Run a single model + downstream
dbt build --select fct_daily_operations+

# Run tests only
dbt test

# Full refresh (rebuild all incremental models from scratch)
dbt build --full-refresh

# Skip circuit breaker (for testing)
dbt build --vars 'skip_circuit_breaker: true'

# Generate and serve docs
dbt docs generate
dbt docs serve
```

---

## Common Operations

### Train ticket demand forecast model
```bash
dbt run-operation create_ticket_demand_forecast
```

### Run only ML features
```bash
dbt run --select ml_features
```

### Rebuild a single silver model from scratch
```bash
dbt run --select silver_pos_tickets --full-refresh
```

### Run reconciliation tests
```bash
dbt test --select test_type:singular
```

---

## Deployment

Production deployment uses Snowflake's native dbt integration:

```sql
-- Deploy project
CREATE OR REPLACE DBT PROJECT museum_dbt
  FROM 'snow://workspace/USER$.PUBLIC."museum-dbt"/versions/live/'
  ...;

-- Execute build
EXECUTE DBT PROJECT museum_dbt
  TARGET = 'prod'
  COMMAND = 'build';
```

Or via Snowflake CLI:
```bash
snow dbt deploy --project-dir . --connection prod
```

See [CHANGELOG.md](CHANGELOG.md) for release history.

---

## Governance

| Document | Purpose |
|----------|---------|
| [CHANGELOG.md](CHANGELOG.md) | Release history with model/test counts per version |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Branching strategy, PR process, commit conventions |
| [CODEOWNERS](CODEOWNERS) | PR approval routing by file path |

### Code Ownership
All files currently owned by `@jwmyers82`. See CODEOWNERS for per-path routing.

### Query Tags
All models emit query tags for Snowflake query history filtering:
- `dbt_museum_staging`
- `dbt_museum_silver`
- `dbt_museum_gold`
- `dbt_museum_ml_features`
- `dbt_museum_snapshots`

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for the full guide. Summary:

1. Create a short-lived feature branch from `main`
2. Develop in your personal dev workspace (`MUSEUM_DW_DEV`)
3. Run `dbt build` to verify
4. Push and open a PR — CI will run slim builds
5. Get review, merge to `main`
6. Deploy to prod via `CREATE DBT PROJECT`
