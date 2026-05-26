# Contributing to museum-dbt

## Branch Strategy: Trunk-Based Development

```
main (production)
 ├── feature/add-donor-segments      ← short-lived (1-3 days max)
 ├── feature/fix-retail-reconcile    ← short-lived
 └── feature/update-campaign-dims    ← short-lived
```

### Rules

1. **`main` is always deployable** — all code on main runs successfully in prod
2. **Feature branches are short-lived** — merge within 1-3 days, never more than a week
3. **No `develop` branch** — we're a small team, no need for integration staging
4. **Deploy from main** — after merge, deploy via `CREATE DBT PROJECT`

### Workflow

```bash
# 1. Create a feature branch from main
git checkout main && git pull
git checkout -b feature/your-change-description

# 2. Work in your personal workspace (writes to your personal dev database)
dbt build --select your_model+

# 3. Run full test suite before PR
dbt build

# 4. Push and create PR
git push -u origin feature/your-change-description
# Open PR → get review → merge to main

# 5. Deploy to prod (run by JMYERS or CI)
# See Deployment section below
```

### Commit Messages

```
feat: add donor retention cohort model
fix: resolve hashdiff null handling in stg_pos_retail
refactor: move gold models into subfolders
test: add orphan detection for member360
docs: update runbook with quarantine steps
```

---

## Workspace Isolation

### Per-Developer Setup

Each contributor gets:
- **Their own Snowflake database**: `MUSEUM_DW_DEV_<USERNAME>` (e.g., `MUSEUM_DW_DEV_JMYERS`)
- **Their own Snowsight workspace**: cloned from the shared repo
- **Shared read access** to `MUSEUM_DW_PROD` for comparison

```
┌─────────────────────────────────────────────────────────┐
│  MUSEUM_DW_PROD        (production — main branch)       │
│  ├── BRONZE             read-only for devs              │
│  ├── SILVER                                             │
│  ├── GOLD                                               │
│  └── ML_FEATURES                                        │
├─────────────────────────────────────────────────────────┤
│  MUSEUM_DW_DEV_JMYERS  (JMYERS personal dev)           │
│  ├── BRONZE             shared — reads from prod bronze │
│  ├── SILVER             personal — writes here          │
│  ├── GOLD               personal — writes here          │
│  └── ML_FEATURES        personal — writes here          │
├─────────────────────────────────────────────────────────┤
│  MUSEUM_DW_DEV_ASMITH  (ASMITH personal dev)           │
│  ├── BRONZE             shared — reads from prod bronze │
│  ├── SILVER             personal — writes here          │
│  ├── GOLD               personal — writes here          │
│  └── ML_FEATURES        personal — writes here          │
└─────────────────────────────────────────────────────────┘
```

### How it works

- `profiles.yml` routes to your personal database via `target.database`
- Bronze data is **shared** (not duplicated) — dev databases create schemas that clone or reference prod bronze
- Each developer's `dbt run` writes to their own isolated schemas
- No one can accidentally overwrite another person's work

### Setting up a new developer

Run the setup script (requires ACCOUNTADMIN):

```sql
-- Replace <USERNAME> with the developer's Snowflake username
-- See scripts/setup_developer_workspace.sql for the full script
```

---

## Ownership Zones

### Model Groups

| Group | Owner | Models | Responsibility |
|-------|-------|--------|----------------|
| `daily_operations` | Museum Analytics Team | stg_pos_tickets → silver_pos_tickets → fct_daily_operations → fct_monthly_operations, fct_visitor_traffic, dim_gate, dim_date | Ticket sales, gate scans, retail ops |
| `member_engagement` | Membership & Development | stg_sf_crm → silver_sf_crm → fct_member_360 → dim_member | CRM data, member profiles, engagement |
| `donor_retention` | Membership & Development | fct_donor_retention → fct_donor_cohort_survival → ml_donor_churn_features | Cohort analysis, churn prediction |
| `campaign_analytics` | Marketing Team | stg_sf_marketing_cloud → silver_sf_marketing_cloud → fct_campaign_performance → dim_campaign | Email campaigns |
| `visitor_forecasting` | Data Science Team | ml_daily_visitor_features, ml_member_churn_features | ML feature tables |

### Rules of Engagement

1. **You own your group's models** — you can modify them freely on your feature branch
2. **Shared models need coordination** — if you need to change a model in someone else's group, tag them on the PR
3. **Silver models are shared infrastructure** — changes to silver require agreement from all downstream group owners
4. **Breaking changes require a heads-up** — if your change will require downstream `--full-refresh`, notify the team in advance

### Who reviews what

| Changed file | Required reviewer |
|-------------|-------------------|
| `models/staging/*` | JMYERS (infra owner) |
| `models/silver/*` | JMYERS (infra owner) |
| `models/gold/facts/fct_donor_*` | Membership team lead |
| `models/gold/facts/fct_daily_*` | Analytics team lead |
| `models/gold/facts/fct_campaign_*` | Marketing team lead |
| `models/ml_features/*` | Data Science team lead |
| `macros/*` | JMYERS (infra owner) |
| `dbt_project.yml` | JMYERS (infra owner) |
| `profiles.yml` | JMYERS (infra owner) |

---

## Developer Targets

### profiles.yml — per-developer routing

Each developer's workspace has a `profiles.yml` that points to their personal database:

```yaml
museum_dbt:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: ""
      user: ""
      role: DBT_DEV_ROLE
      database: MUSEUM_DW_DEV_<YOUR_USERNAME>   # ← personal database
      warehouse: DBT_DEV_WH
      schema: SILVER
      threads: 4
    prod:
      type: snowflake
      account: ""
      user: ""
      role: DBT_PROD_ROLE
      database: MUSEUM_DW_PROD
      warehouse: DBT_PROD_WH
      schema: SILVER
      threads: 8
```

### Running against production (read-only comparison)

```bash
# Compare your dev output to prod
dbt run --select model_name --target prod  # CAREFUL: writes to prod
```

**Never run `dbt run --target prod` unless you are deploying.** For comparison, query prod directly:

```sql
SELECT COUNT(*) FROM MUSEUM_DW_PROD.GOLD.FCT_DAILY_OPERATIONS;
SELECT COUNT(*) FROM MUSEUM_DW_DEV_JMYERS.GOLD.FCT_DAILY_OPERATIONS;
```

---

## Deployment

### From workspace to production

Only JMYERS (or CI) deploys to production:

```sql
-- Deploy latest from main branch workspace
CREATE OR REPLACE DBT PROJECT MUSEUM_DW_PROD.SILVER.MUSEUM_DBT
  FROM 'snow://workspace/USER$.PUBLIC."museum-dbt"/versions/live';

-- Run full build in prod
EXECUTE DBT PROJECT MUSEUM_DW_PROD.SILVER.MUSEUM_DBT ARGS = 'build';
```

### After merging a breaking change

If the PR includes schema changes to incremental models:

```sql
EXECUTE DBT PROJECT MUSEUM_DW_PROD.SILVER.MUSEUM_DBT ARGS = 'build --full-refresh --select changed_model+';
```

---

## Pre-PR Checklist

Before opening a pull request, verify:

- [ ] `dbt compile` passes with no errors
- [ ] `dbt build --select your_model+` passes in your dev database
- [ ] All new models have entries in the appropriate `schema.yml`
- [ ] New models have a `group` config if they belong to a domain
- [ ] Tests added for any new business logic
- [ ] `CHANGELOG.md` updated with your changes
- [ ] If changing silver/staging, all downstream tests still pass: `dbt test`
- [ ] If adding a new source, updated circuit breaker + rerun_from_source
- [ ] `dbt run-operation validate_before_deploy` shows no FAIL results
- [ ] If Tier 1 change: change gate approval obtained (see below)

---

## Change Gate Classification

Per the NS11MM IaC policy, changes are classified by tier. This applies to the dbt project as well as infrastructure.

### Tier 1 — Infrastructure Changes (72-hour notice + approval required)

Any change to these files is a Tier 1 change:

| File | Why it's Tier 1 |
|------|-----------------|
| `dbt_project.yml` | Controls all model materializations, hooks, and vars |
| `profiles.yml` | Controls database/warehouse routing |
| `macros/data_quality/check_source_group_readiness.sql` | Circuit breaker — can block all runs |
| `macros/data_quality/check_source_freshness.sql` | Source SLA definitions |
| `macros/generate_schema_name.sql` | Schema routing for all models |
| `.github/workflows/dbt-ci.yml` | CI/CD pipeline definition |
| `scripts/setup_developer_workspace.sql` | Access control and permissions |
| `CODEOWNERS` | PR approval gates |

**Process:**
1. File a Change Log entry (see RUNBOOK.md)
2. Post 72-hour advance notice in Teams data channel
3. Get written approval from JMYERS
4. Merge PR (CODEOWNERS enforces reviewer)
5. Deploy to staging first: `dbt build --target staging`
6. Validate staging, then deploy to prod
7. Post-deploy validation + Teams notification

### Tier 2 — Model Changes (standard PR process)

Any change to model SQL, schema.yml, or tests follows the standard PR workflow:
1. Feature branch → build in dev → PR → CI passes → merge → deploy

### Emergency Changes

If a Tier 1 change is needed urgently (pipeline is down, data is stale):
1. Make the change on a branch
2. Get verbal approval from JMYERS (Teams/Slack/phone)
3. Merge with `[EMERGENCY]` prefix in commit message
4. File the Change Log entry retroactively within 24 hours
5. Post-incident review within 48 hours

---

## Environment Promotion

```
dev (personal database)
 → staging (MUSEUM_DW_STAGING — integration validation)
   → prod (MUSEUM_DW_PROD — live data)
```

| Step | Command | Gate |
|------|---------|------|
| Dev build | `dbt build --target dev` | Tests pass |
| Pre-deploy check | `dbt run-operation validate_before_deploy` | No FAIL results |
| Staging deploy | `dbt build --target staging` | Matches dev output |
| Prod deploy | `CREATE DBT PROJECT` or `dbt build --target prod` | JMYERS approval |

**Never skip staging for Tier 1 changes.** Model-only changes (Tier 2) may go dev → prod if CI passes and validate_before_deploy shows MATCH.

---

## Verified Query (VQR) Workflow

Verified queries live in `analyses/verified_queries/` organized by business domain. They are the source of truth for what the Cortex Agent knows how to answer accurately.

### Adding a New VQR

1. **Identify the domain** — pick the folder (`revenue_operations/`, `ticket_sales/`, etc.)
2. **Write the SQL** — create `my_query_name.sql` using `SEMANTIC_VIEW()` syntax:
   ```sql
   SELECT *
   FROM SEMANTIC_VIEW(museum_dw_prod.gold.sv_museum_operations
     METRICS metric1, metric2
     DIMENSIONS dim1, dim2
     WHERE filter_condition)
   ```
3. **Add metadata** — append to the domain's `_verified_queries.yml`:
   ```yaml
   - name: my_query_name
     description: >
       Business context and who uses this.
     file: my_query_name.sql
     semantic_view: MUSEUM_DW_PROD.GOLD.SV_MUSEUM_OPERATIONS
     question: "Natural language question this answers"
     stakeholder_owner: Owner Name
     adm_reference: ADR-XXX-XX-XXX
     approved_by: approver_username
     approved_date: "YYYY-MM-DD"
     tags: [domain, certified]
     power_bi_datasets:
       - Dataset Name
   ```
4. **Validate** — run `dbt compile` (ensures SQL parses)
5. **PR and merge** — standard PR process, CI will trigger on `analyses/` changes
6. **Deploy to semantic view** — after merge, rebuild the semantic view with the new VQR in the `AI_VERIFIED_QUERIES` section

### VQR Governance Rules

- All VQRs must have `approved_by` and `approved_date` before deployment
- Only queries tagged `certified` get synced to semantic views
- Run `dbt run-operation sync_verified_queries` to list all registered VQRs
- VQRs tagged `action_required` trigger proactive monitoring alerts

### Removing/Deprecating a VQR

1. Remove the entry from `_verified_queries.yml`
2. Delete the `.sql` file
3. Rebuild the semantic view without that VQR
4. PR with note explaining why (question no longer relevant, data model changed, etc.)

---

## Snowsight Workspace ↔ GitHub Sync

The shared workspace (`MUSEUM_DW_DEV.PUBLIC."museum-dbt"`) does **not** have direct Git push/pull. All code changes must go through GitHub before being published to other users.

### Golden Rule

**Never click "Publish Changes" in Snowsight until your PR has been merged in GitHub.**

Publishing makes your edits visible to all workspace users. If you publish unreviewed code, you bypass the PR process.

### Pushing Changes to GitHub

```bash
# 1. Download your workspace edits to your local clone
snow stage copy "snow://workspace/MUSEUM_DW_DEV.PUBLIC.""museum-dbt""/versions/live/" C:\Users\<your-username>\museum-dbt\ --recursive

# 2. Create a feature branch
cd C:\Users\<your-username>\museum-dbt
git checkout main && git pull
git checkout -b feature/your-change-description

# 3. Stage, commit, push
git add .
git commit -m "feat: describe your changes"
git push -u origin feature/your-change-description

# 4. Open a PR at https://github.com/jmyers911mm/museum-dbt/pulls
```

### After Your PR is Merged

```sql
-- Sync the Snowflake Git repo with GitHub
ALTER GIT REPOSITORY MUSEUM_DW_DEV.PUBLIC.museum_dbt_repo FETCH;
```

Then click **"Publish Changes"** in Snowsight to make the merged code live for all workspace users.

### Checking Your Status

| Question | How to check |
|----------|-------------|
| Am I up to date with `main`? | `git fetch origin && git status` — look for "up to date" vs "behind" |
| Do I have unpushed local changes? | `git status` — "ahead" means you have commits that need a PR |
| Do I have unpublished Snowsight edits? | Look for the "Publish Changes" button in the workspace |
| Is the Snowflake Git repo current? | `ALTER GIT REPOSITORY MUSEUM_DW_DEV.PUBLIC.museum_dbt_repo FETCH;` — "No change" means current |
| Do I need to pull? | `git pull origin main` to get the latest merged code |

### Snowflake CLI Setup

Your `%USERPROFILE%\.snowflake\config.toml` must be configured:

```toml
[connections.default]
account = "om01578.east-us.azure"
user = "YOURUSER@911MEMORIAL.ORG"
password = "your_password"
role = "ACCOUNTADMIN"
warehouse = "COMPUTE_WH"
database = "MUSEUM_DW_DEV"
schema = "PUBLIC"
```

Test with: `snow connection test`

### Workflow Diagram

```
┌──────────────────────────────────────────────────────────────┐
│  YOU (in Snowsight workspace)                                │
│  Edit files → DO NOT publish yet                             │
└──────────────┬───────────────────────────────────────────────┘
               │ snow stage copy (download)
               ▼
┌──────────────────────────────────────────────────────────────┐
│  YOUR LOCAL MACHINE                                          │
│  git checkout -b feature/... → git add → git commit → push  │
└──────────────┬───────────────────────────────────────────────┘
               │ git push
               ▼
┌──────────────────────────────────────────────────────────────┐
│  GITHUB                                                      │
│  Open PR → Review → Approve → Merge to main                 │
└──────────────┬───────────────────────────────────────────────┘
               │ merged
               ▼
┌──────────────────────────────────────────────────────────────┐
│  SNOWFLAKE                                                   │
│  ALTER GIT REPOSITORY ... FETCH → Publish Changes            │
└──────────────────────────────────────────────────────────────┘
```

---

## SQL Style Guide
