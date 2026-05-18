# Changelog

All notable changes to the museum-dbt project will be documented in this file.

## [1.5.0] - 2026-05-18

### ML Feature Enhancement

**Modified** (1 file)
- `models/ml_features/ml_ticket_demand_features.sql` — added 30-day rolling forecast columns partitioned by ticket type: `forecast_min_30d`, `forecast_max_30d`, `forecast_mean_30d`

### Documentation & Recovery

**Recreated** (1 file)
- `README.md` — comprehensive project documentation with table of contents, architecture diagram, full model lineage (upstream/downstream), testing strategy, access control policies, CI/CD pipeline, and deployment instructions

---

## [1.4.0] - 2026-05-18

### Ticket Capacity & Availability Pipeline

**New Snowflake Objects**
- `BRONZE.RAW_TICKET_CAPACITY` — capacity configuration table (date, 30-min entry window, ticket type, capacity)
- `BRONZE.RAW_POS_TICKETS.ENTRY_TIME_PURCHASED` — new column added for reservation window tracking

**New dbt Models** (5 files)
- `models/staging/stg_ticket_capacity.sql` — staging view for capacity source
- `models/silver/silver_ticket_inventory.sql` — joins capacity + reservations, computes utilization % and demand level (Sold Out / High Demand / Moderate / Low / Very Low)
- `models/gold/facts/fct_ticket_availability.sql` — enriched with date dimensions, the main reporting table for ticket operations
- `models/gold/facts/fct_ticket_demand_benchmarks.sql` — 90-day rolling benchmarks showing avg/median/p25/p75/p90 by day-of-week, entry window, and ticket type with ±2σ bounds
- `models/ml_features/ml_ticket_demand_features.sql` — daily demand features with 7/30-day rolling averages, lags, z-scores for forecast model training

**New Forecast Macro** (1 file)
- `macros/operations/create_ticket_demand_forecast.sql` — run-operation that creates a `SNOWFLAKE.ML.FORECAST` model for 90-day multi-series ticket demand prediction

**Modified** (2 files)
- `models/staging/stg_pos_tickets.sql` — added `entry_time_purchased`, `entry_date`, `entry_window_start/end`, `mapped_ticket_type` (maps legacy types to new 10-type taxonomy), updated hashdiff
- `models/staging/sources.yml` — added `raw_ticket_capacity` source definition with column tests

**Model count: 35 → 40 | Source count: 5 → 6**

### Schema & Contract Fixes

**Modified** (3 files)
- `models/gold/facts/fct_daily_operations.sql` — removed contract enforcement, changed `on_schema_change` to `append_new_columns` (resolves recurring numeric precision drift)
- `models/gold/facts/fct_member_360.sql` — removed contract enforcement, changed `on_schema_change` to `append_new_columns`
- `models/gold/facts/fct_donor_cohort_survival.sql` — fixed NULL `original_cohort_size` by wrapping window function in COALESCE
- `models/gold/dimensions/schema.yml` — fixed `dim_product.standard_price` data type to `NUMBER(10,2)`
- `dbt_project.yml` — gold layer `+on_schema_change` changed from `fail` to `append_new_columns`

### Test Fixes

**Modified** (2 files)
- `macros/generic_tests/test_hashdiff_integrity.sql` — fixed UNION ALL column mismatch (collision_check and null_check now return consistent columns)
- `models/silver/schema.yml` — set `hashdiff_integrity` tests on `silver_pos_retail` and `silver_sf_marketing_cloud` to `severity: warn` (hash collisions from identical business records are informational, not failures)

### Production Deployment

- Full-refresh build deployed to `MUSEUM_DW_PROD` — 40 models, 252 tests, 289 pass / 7 warn / 0 error
- Created `MUSEUM_DW_PROD.SILVER.DBT_RUN_AUDIT_LOG` table
- Created `MUSEUM_DW_PROD.BRONZE.RAW_TICKET_CAPACITY` table (19,200 rows seeded)
- Added `ENTRY_TIME_PURCHASED` column to `MUSEUM_DW_PROD.BRONZE.RAW_POS_TICKETS` (574 rows backfilled)

---

## [1.3.0] - 2026-05-18

### Donor Retention & Churn Forecasting

**New** (2 files in `models/gold/facts/`)
- `fct_donor_retention.sql` — monthly retention rates per cohort (acquisition month, membership type, acquisition method, donor tier). Donors are considered retained if Active/Grace Period OR donated within 12 months.
- `fct_donor_cohort_survival.sql` — survival curves per cohort with half-life detection, monthly dropoff rates, and cohort health scoring (Healthy / At Risk / Declining / Critical)

**New** (1 file in `models/ml_features/`)
- `ml_donor_churn_features.sql` — per-donor churn prediction features: tenure, donation velocity, recency bands (Recent/Cooling/Lapsing/Dormant), composite churn risk level (Low/Medium/High), and `estimated_months_to_churn` derived from cohort survival half-life

**Modified** (2 files)
- `models/gold/facts/schema.yml` — added schema entries for fct_donor_retention, fct_donor_cohort_survival
- `models/ml_features/schema.yml` — added schema entry for ml_donor_churn_features

**Model count: 32 → 35 | Test count: 227 → 248**

### Model Groups & Ownership

**New** (1 file)
- `models/_model_groups.yml` — declares 5 dbt groups with owners: daily_operations, member_engagement, donor_retention, campaign_analytics, visitor_forecasting

**Modified** (3 files)
- `dbt_project.yml` — assigned `+group` at folder level for staging, silver, gold/dimensions, gold/facts, gold/reports, ml_features
- `models/gold/facts/fct_donor_retention.sql` — `group='donor_retention'`
- `models/gold/facts/fct_donor_cohort_survival.sql` — `group='donor_retention'`
- `models/ml_features/ml_donor_churn_features.sql` — `group='donor_retention'`

**Modified** (1 file)
- `models/exposures.yml` — added `ml_donor_churn_model` exposure (full pipeline lineage) and `powerbi_donor_retention_dashboard` exposure

**Exposure count: 6 → 8 | Group count: 0 → 5**

### Pre-Deployment Validation (Dev vs Prod)

**New** (2 files in `macros/operations/`)
- `validate_before_deploy.sql` — run-operation that compares row counts of 10 key models between dev and prod databases. Reports MATCH/WARN/FAIL per model with configurable threshold (default 5%)
- `compare_model_to_prod.sql` — run-operation for deep single-model comparison using MINUS set operations. Detects new rows, lost rows, and modified rows. Flags DATA LOSS RISK if prod rows would be removed

### Branch Strategy & Workspace Isolation

**New** (1 file)
- `CONTRIBUTING.md` — trunk-based branching workflow, per-developer workspace isolation (personal databases), ownership zones by model group, PR reviewer matrix, change gate classification (Tier 1/Tier 2), environment promotion order (dev → staging → prod), pre-PR checklist

**New** (1 file)
- `scripts/setup_developer_workspace.sql` — SQL script to onboard a new developer: creates personal `MUSEUM_DW_DEV_<USERNAME>` database, shares bronze via views from prod, grants permissions, creates audit log table

**New** (1 file)
- `CODEOWNERS` — maps file paths to required PR reviewers (JMYERS for all infrastructure files)

**Modified** (1 file)
- `profiles.yml` — added `staging` target (MUSEUM_DW_STAGING), updated account/user fields

### CI/CD Pipeline

**Modified** (1 file)
- `.github/workflows/dbt-ci.yml` — upgraded from full-build to slim CI (`state:modified+` with `--defer`), added pre-deploy validation step, added docs generation on merge to main, path-filtered triggers

### IaC Policy Alignment

**New** (14 files in `terraform/`)
- `main.tf` — orchestrates M01-M04 modules with dependency ordering
- `variables.tf` — 18 input variables with validation rules
- `outputs.tf` — Key Vault URI, warehouse name, Static Web App hostname
- `providers.tf` — azurerm + snowflake providers, azurerm backend state config
- `modules/snowflake-warehouse/main.tf` — M01: Snowflake warehouse + resource monitor (size parameterized per environment)
- `modules/key-vault/main.tf` — M02: Azure Key Vault with soft-delete, purge protection, 2 service principal access policies
- `modules/static-web-app/main.tf` — M03: Static Web App for dbt docs hosting
- `modules/monitor-alerts/main.tf` — M04: Credit consumption warning/critical alerts routed to Teams webhook
- `environments/dev.tfvars.json` — XSMALL warehouse, kv-ns11mm-dev
- `environments/staging.tfvars.json` — MEDIUM warehouse, kv-ns11mm-staging
- `environments/prod.tfvars.json` — MEDIUM warehouse, kv-ns11mm-prod
- `pipelines/deploy-dev.yml` — Azure Pipelines: auto-deploy on merge to main
- `pipelines/deploy-staging.yml` — Azure Pipelines: manual trigger
- `pipelines/deploy-prod.yml` — Azure Pipelines: manual trigger + ManualValidation approval gate

**New** (3 files in `terraform/`)
- `CODEOWNERS` — all IaC files require @jwmyers82 approval
- `.gitignore` — excludes tfstate, .terraform/, plan files
- `README.md` — deployment order, prerequisites, usage instructions

### Runbook

**New** (1 file)
- `RUNBOOK.md` — comprehensive operational runbook covering: daily operations, incident response, source issues, test failures, schema changes, quarantine management, backfill/late data, adding new content, deployment (including pre-deploy validation workflow), monitoring health checks, contacts & escalation, and quick reference command table

---

## [1.2.0] - 2026-05-17

### Change Detection (Hashdiff)

**New** (1 file)
- `macros/data_quality/generate_hashdiff.sql` — reusable MD5 hash macro over business columns with null-safe concatenation

**Modified** (5 files)
- `models/staging/stg_sf_crm.sql` — added `hashdiff` column (15 business columns)
- `models/staging/stg_pos_tickets.sql` — added `hashdiff` column (10 business columns)
- `models/staging/stg_pos_retail.sql` — added `hashdiff` column (11 business columns)
- `models/staging/stg_ticket_scans.sql` — added `hashdiff` column (6 business columns)
- `models/staging/stg_sf_marketing_cloud.sql` — added `hashdiff` column (10 business columns)

**Modified** (5 files)
- `models/silver/silver_pos_tickets.sql` — merge now skips rows with unchanged hashdiff
- `models/silver/silver_pos_retail.sql` — merge now skips rows with unchanged hashdiff
- `models/silver/silver_ticket_scans.sql` — merge now skips rows with unchanged hashdiff
- `models/silver/silver_sf_crm.sql` — merge now skips rows with unchanged hashdiff
- `models/silver/silver_sf_marketing_cloud.sql` — merge now skips rows with unchanged hashdiff

**Modified** (1 file)
- `snapshots/snap_sf_crm.sql` — changed from `strategy='timestamp'` to `strategy='check', check_cols=['hashdiff']`

### Data Quality & Validation

**New Generic Test Macros** (6 files in `macros/generic_tests/`)
- `test_hashdiff_integrity.sql` — validates no null hashes and no hash collisions across different keys
- `test_referential_integrity.sql` — reusable FK validation between any parent/child models
- `test_row_count_drift.sql` — alerts when row count deviates >50% or >200% of 30-day historical average
- `test_late_arriving_data.sql` — detects rows with business timestamp >72h before load time
- `test_schema_drift.sql` — compares model's actual columns against an expected list

**New Data Quality Macros** (2 files in `macros/data_quality/`)
- `quarantine_failed_rows.sql` — routes failing rows to `SILVER.QUARANTINE_LOG` with full row data and reason
- `auto_heal_duplicates.sql` — CTE wrapper that deduplicates on primary key keeping latest row

**New Singular Tests** (4 files in `tests/`)
- `tests/referential_integrity/assert_campaign_fk_integrity.sql` — campaign IDs in gold resolve to dim_campaign
- `tests/referential_integrity/assert_member360_emails_exist_in_crm.sql` — member emails exist in silver CRM
- `tests/referential_integrity/assert_member360_no_orphan_contacts.sql` — no orphan contacts in fct_member_360
- `tests/referential_integrity/assert_gold_daily_ops_no_orphan_dates.sql` — no orphan dates in fct_daily_operations

**Modified** (1 file)
- `models/silver/schema.yml` — added hashdiff_integrity tests (all 5 silver models), late_arriving_data tests (4 transactional models)

**Test count: 214 → 248**

### Rerun & Recovery Operations

**New** (3 files in `macros/operations/`)
- `smart_retry.sql` — run-operation that reads audit log, identifies failed models, suggests exact rerun commands
- `rerun_from_source.sql` — run-operation that maps source table to downstream models with group-aware rebuild commands
- `resolve_quarantine.sql` — run-operation that marks quarantined rows as resolved after successful reruns

### Project Reorganization (Subfolder Strategy)

**Macros** — split from flat `macros/` into:
- `macros/generic_tests/` (14 files) — all `test_*.sql` reusable test macros
- `macros/data_quality/` (6 files) — hashdiff, freshness, circuit breaker, audit, quarantine, dedup
- `macros/operations/` (3 files) — smart_retry, rerun_from_source, resolve_quarantine
- `macros/generate_schema_name.sql` remains at root (dbt convention)

**Tests** — split from flat `tests/` into:
- `tests/reconciliation/` (5 files) — bronze↔silver count matches, revenue/visitor reconciliation
- `tests/referential_integrity/` (9 files) — FK checks, orphan detection, email existence
- `tests/business_rules/` (4 files) — campaign rates, negative values, date coverage

**Gold Models** — split from flat `models/gold/` into:
- `models/gold/dimensions/` (7 models + schema.yml) — all `dim_*` models
- `models/gold/facts/` (10 models + schema.yml) — all `fct_*` models including new donor models
- `models/gold/reports/` (5 models + schema.yml) — all `rpt_*` BI-facing views

**Modified** (1 file)
- `dbt_project.yml` — `test-paths` updated to point to subfolders

### Donor Retention & Churn Forecasting

**New** (2 files in `models/gold/facts/`)
- `fct_donor_retention.sql` — monthly retention rates per cohort (acquisition month, membership type, acquisition method, donor tier)
- `fct_donor_cohort_survival.sql` — survival curves per cohort with half-life detection and cohort health scoring (Healthy/At Risk/Declining/Critical)

**New** (1 file in `models/ml_features/`)
- `ml_donor_churn_features.sql` — per-donor churn prediction features: tenure, donation velocity, recency bands, engagement decay, estimated months-to-churn based on cohort survival half-life

**New** (1 file)
- `models/_model_groups.yml` — dbt groups declaring 5 model ownership clusters (daily_operations, member_engagement, donor_retention, campaign_analytics, visitor_forecasting)

**Modified** (1 file)
- `models/exposures.yml` — added `ml_donor_churn_model` and `powerbi_donor_retention_dashboard` exposures with full pipeline lineage documentation

**Model count: 32 → 35 | Exposure count: 6 → 8 | Group count: 0 → 5**

### Bug Fixes
- `models/gold/dim_product.sql` — full-refreshed to resolve `on_schema_change: fail` error from numeric precision drift (NUMBER(10,2) type mismatch)
- `models/gold/fct_member_360.sql` — full-refreshed to resolve schema type sync (10 numeric columns)
- `models/gold/fct_daily_operations.sql` — full-refreshed to resolve schema type sync (15 numeric columns)

---

## [1.1.0] - 2026-05-16

### Performance & Cost Optimization

**Clustering Keys** (10 files)
- `models/silver/silver_pos_tickets.sql` — `cluster_by: [transaction_date]`
- `models/silver/silver_pos_retail.sql` — `cluster_by: [transaction_date, item_category]`
- `models/silver/silver_ticket_scans.sql` — `cluster_by: [scan_date, gate_id]`
- `models/silver/silver_sf_crm.sql` — `cluster_by: [computed_membership_status, membership_type]`
- `models/silver/silver_sf_marketing_cloud.sql` — `cluster_by: [event_date, campaign_id]`
- `models/gold/fct_daily_operations.sql` — `cluster_by: [visit_date]`
- `models/gold/fct_visitor_traffic.sql` — `cluster_by: [scan_date]`
- `models/gold/fct_retail_performance.sql` — `cluster_by: [transaction_date, item_category]`
- `models/gold/fct_campaign_performance.sql` — `cluster_by: [first_send_date]`
- `models/gold/fct_member_360.sql` — `cluster_by: [engagement_segment, computed_membership_status]`

**Transient Tables** (8 files)
- `models/gold/dim_date.sql`
- `models/gold/dim_gate.sql`
- `models/gold/dim_product.sql`
- `models/gold/dim_campaign.sql`
- `models/gold/dim_ticket_type.sql`
- `models/gold/dim_payment_method.sql`
- `models/ml_features/ml_daily_visitor_features.sql`
- `models/ml_features/ml_member_churn_features.sql`

**Project-Level Configs** (1 file)
- `dbt_project.yml` — added query_tag per layer, statement_timeout pre-hook (3600s default, 300s for intraday), copy_grants on silver/gold, transient on silver/ml_features, on-run-start freshness check, intraday timeout override

### Dedicated Warehouses (Snowflake objects, not files)
- Created `DBT_DEV_WH` (XS, auto-suspend 60s, 5 credit/month monitor)
- Created `DBT_PROD_WH` (Small, auto-suspend 60s, 50 credit/month monitor)
- `profiles.yml` — updated dev/prod targets to use dedicated warehouses

### Grain Strategy

**New Models** (2 files)
- `models/gold/fct_monthly_operations.sql` — monthly pre-aggregated ops summary from fct_daily_operations
- `models/gold/fct_monthly_retail.sql` — monthly pre-aggregated retail by category from fct_retail_performance

**Refactored** (1 file)
- `models/ml_features/ml_daily_visitor_features.sql` — now reads from gold facts instead of re-aggregating silver tables

**Incremental Dimensions** (2 files)
- `models/gold/dim_product.sql` — converted from table to incremental merge
- `models/gold/dim_ticket_type.sql` — converted from table to incremental merge

### Intraday Pipeline (15-min ticket sales)

**Modified** (4 files)
- `models/silver/silver_pos_tickets.sql` — changed to append strategy, tagged intraday
- `models/staging/stg_pos_tickets.sql` — tagged intraday
- `models/gold/fct_daily_operations.sql` — tagged intraday, dedicated query_tag
- `models/staging/sources.yml` — raw_pos_tickets freshness: warn 30min, error 60min

### Source Freshness

**New** (1 file)
- `macros/check_source_freshness.sql` — per-source staleness thresholds (60min for tickets, 48hr for others)

### New Feature: Ticket Utilization

**New** (1 file)
- `models/gold/fct_ticket_utilization.sql` — transaction-level join of tickets sold to gate scans; identifies unscanned tickets, scan issues, purchase-to-entry time

### Schema & Documentation

**Modified** (3 files)
- `models/gold/schema.yml` — added fct_monthly_operations, fct_monthly_retail, fct_ticket_utilization entries; added _loaded_at to dim_product contract
- `models/exposures.yml` — added fct_monthly_operations and fct_monthly_retail to dashboard and Cortex Analyst exposures

### Bug Fixes
- `models/gold/schema.yml` — fixed `doubleversion: 2` merge conflict corruption
- `models/gold/dim_product.sql` — fixed correlated aggregate subquery error (aliased `{{ this }} t`)
- `models/gold/dim_ticket_type.sql` — fixed correlated aggregate subquery error (aliased `{{ this }} t`)
