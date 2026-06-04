# Onboarding — Data Team

A linear, day-one checklist for new contributors to the `ns11mm-dbt` project. Work top to bottom; by the end you'll have a working personal workspace and your first successful build.

For the *why* behind any step, follow the links into [CONTRIBUTING](../CONTRIBUTING.md) and the [README](../README.md).

---

## Before you start — access you'll need

Ask your lead / the CIO's office to provision these before day one:

- [ ] **GitHub access** to `jmyers911mm/ns11mm-dbt` (write access if you'll contribute)
- [ ] **Snowflake account** with `DBT_DEV_ROLE`
- [ ] **A personal dev database** — `NS11MM_DW_DEV_<YOURUSERNAME>` (created via `scripts/setup_developer_workspace.sql`, run by an admin)
- [ ] **Read access** to `NS11MM_DW_PROD` (for comparison only — never write to it)
- [ ] **Membership** in the Teams data channel (for change notices and alerts)
- [ ] **Access to the Platform Hub** (registries, runbook, ADR log)

---

## Step 1 — Read the lay of the land (30 minutes)

- [ ] Skim the [README](../README.md) — focus on **Architecture**, **Data Layers**, and **Model Lineage**.
- [ ] Read [CONTRIBUTING](../CONTRIBUTING.md) — focus on **Branch Strategy**, **Ownership Zones**, and **Change Gate Classification**.
- [ ] Read the [SQL Style Guide](architecture/SQL_STYLE_GUIDE.md).
- [ ] Skim [Data Classification](architecture/DATA_CLASSIFICATION.md) so you know what PII looks like before you touch it.

You don't need to memorize anything — just know where to look.

## Step 2 — Set up your machine

- [ ] Install Python (3.x) and create a virtual environment.
- [ ] Install dbt with the Snowflake adapter (or use a Snowsight Workspace).
- [ ] Clone the repo:
  ```
  git clone https://github.com/jmyers911mm/ns11mm-dbt.git
  cd ns11mm-dbt
  ```
- [ ] Install project packages:
  ```
  dbt deps
  ```

## Step 3 — Point dbt at *your* database

Create your `profiles.yml` so your builds write only to your personal database. Use your own Snowflake username in the `database` field:

```yaml
museum_dbt:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: ""              # ask your lead for the account locator
      user: ""                 # your Snowflake username
      role: DBT_DEV_ROLE
      database: NS11MM_DW_DEV_<YOUR_USERNAME>   # ← personal database
      warehouse: DBT_DEV_WH
      schema: SILVER
      threads: 4
```

> **Why your own database?** Each developer's builds are fully isolated, so no one can overwrite anyone else's work. Bronze data is shared (read from prod), so you don't duplicate raw data. See *Workspace Isolation* in [CONTRIBUTING](../CONTRIBUTING.md).

## Step 4 — Run your first build

- [ ] Confirm dbt can connect and parse:
  ```
  dbt debug
  dbt compile
  ```
- [ ] Build everything into your personal database:
  ```
  dbt build
  ```
- [ ] Confirm it worked — you should see your models and passing tests. Spot-check a table in Snowsight:
  ```sql
  SELECT COUNT(*) FROM NS11MM_DW_DEV_<YOUR_USERNAME>.GOLD.FCT_DAILY_OPERATIONS;
  ```

If the build fails, check the [RUNBOOK](../RUNBOOK.md) common-failures section before asking — it covers the usual suspects (freshness, circuit breaker, full-refresh).

## Step 5 — Make a tiny change end-to-end (your first PR)

Practice the workflow with something harmless (e.g., improving a model description):

- [ ] Branch: `git checkout -b feature/onboarding-<yourname>`
- [ ] Make the change; add/adjust the entry in the relevant `schema.yml`.
- [ ] Build just the affected model and its children: `dbt build --select your_model+`
- [ ] Update [CHANGELOG.md](../CHANGELOG.md).
- [ ] Run the [Pre-PR Checklist](../CONTRIBUTING.md#pre-pr-checklist).
- [ ] Push and open a PR. CI runs a slim build automatically.
- [ ] Get review (CODEOWNERS routes it to the right person), then merge.

That's the whole loop. Every future change follows the same path.

---

## Know your boundaries (important)

- **You own your group's models** and can change them freely on a branch. You'll find which group is yours in [CONTRIBUTING → Ownership Zones](../CONTRIBUTING.md#ownership-zones).
- **Silver and staging are shared infrastructure** — changes there need agreement from downstream owners and are owned by the infra lead.
- **Tier 1 files** (e.g., `dbt_project.yml`, `profiles.yml`, CI config, schema-routing macros) require 72-hour notice and approval. See [Change Gate Classification](../CONTRIBUTING.md#change-gate-classification).
- **Never run `dbt run --target prod`** unless you are deploying. For comparing to prod, *query* prod read-only.

---

## Where to go next

- Adding a certified metric for the AI assistant? → [VQR Workflow](../CONTRIBUTING.md#verified-query-vqr-workflow)
- Something's broken in prod? → [RUNBOOK](../RUNBOOK.md)
- Why is it built this way? → [ADR Log](adr/README.md)
- The whole documentation set → [Documentation Map](README.md)

Welcome aboard.
