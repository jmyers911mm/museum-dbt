# RUNBOOK — Museum Data Platform Operations

Operational procedures for running, monitoring, and recovering the `ns11mm-dbt` platform. This is the on-call reference. The **DQ Incident Log**, **Change Log**, and **Rollback Package** records live in the Platform Hub; this runbook tells you the procedures and where to record them.

**Audience:** data team and on-call. **Escalation owner:** Jeremy Myers (infra owner).

---

## At a glance

| You need to… | Go to |
| --- | --- |
| Understand what runs automatically and when | [Scheduled jobs](#scheduled-jobs) |
| Diagnose a failed or stale build | [Common failures](#common-failures-and-fixes) |
| Handle bad/late data | [Data quality incidents & quarantine](#data-quality-incidents--quarantine) |
| Undo a bad deploy | [Rollback](#rollback) |
| Make a controlled change | [Change Log procedure](#change-log-procedure) |
| Know who to wake up | [Escalation](#escalation) |

---

## Scheduled jobs

The platform runs on a Snowflake task DAG plus monitoring tasks. Confirm exact schedules in Snowsight (`SHOW TASKS`); the cadence is:

| Job | Cadence | Purpose |
| --- | --- | --- |
| Core build (staging → silver → gold → ML) | Daily, overnight | Refreshes all analytics tables for the new day |
| Source freshness check | Hourly | Detects late/missing source data before it reaches dashboards |
| Agent pattern analysis (`MONITORING.TASK_AGENT_PATTERN_ANALYSIS`) | Daily, ~8 AM ET | Flags coverage gaps in the Cortex Agent |
| Log purge | Weekly | Trims observability/audit logs |

**Health signals to watch:**
- `SILVER.DBT_RUN_AUDIT_LOG` — every run writes an entry here (via the on-run-end hook). No entry = the run didn't complete.
- Freshness alerts — surfaced via email + Teams.
- `MONITORING.AGENT_QUESTION_PATTERNS` — agent coverage gaps (>50% failure on a pattern = HIGH).

---

## How a run protects itself

Two safeguards run automatically; understand them before overriding:

- **Source freshness check (on-run-start):** verifies sources are current. Stale sources can halt the run by design.
- **Circuit breaker (on-run-start):** stops the build if upstream readiness checks fail, so bad data doesn't propagate to Gold.

To bypass the circuit breaker **only when you've confirmed it's a false alarm**:
```
dbt build --vars 'skip_circuit_breaker: true'
```
> Bypassing is a judgment call, not a default. If you bypass, note why in the Change Log.

---

## Common failures and fixes

### Build failed on a freshness or circuit-breaker check
1. Check which source is stale (freshness alert / `sources.yml` thresholds).
2. Confirm with the source-system owner whether data is genuinely late.
3. If the source is fine and the check is a false positive, rerun with `skip_circuit_breaker: true` and record it.
4. If the source is genuinely late, **wait** — don't force stale data into Gold. Notify stakeholders if dashboards will be behind.

### A test failed in CI or in a run
1. Read the failing test — is it a **schema test** (data shape) or a **business/reconciliation test** (logic)?
2. **Reconciliation failures** (silver vs. bronze counts, revenue mismatch) usually mean upstream data changed or a transform broke — investigate the model, don't loosen the test.
3. **Business-rule failures** (negative revenue, rate > 100%) mean bad data or a logic bug — quarantine if needed (below).
4. Never delete or weaken a test to make a build pass. If a threshold is genuinely wrong, change it deliberately with a note.

### Incremental model looks wrong / partially built
- Rebuild it from scratch:
  ```
  dbt build --select <model> --full-refresh
  ```
- If a schema change is the cause, rebuild the model **and downstream**:
  ```
  dbt build --select <model>+ --full-refresh
  ```

### Dashboards are behind
- Check `SILVER.DBT_RUN_AUDIT_LOG` for last successful run.
- Check freshness alerts for a late source.
- If the build succeeded but Power BI is stale, the issue is on the BI refresh side, not dbt.

---

## Data quality incidents & quarantine

When bad data is detected (failed reconciliation, anomaly alert, stakeholder report):

1. **Triage.** Identify the affected model(s) and the blast radius (what's downstream — see Model Lineage in the README).
2. **Contain (quarantine).** Stop bad data from spreading:
   - Hold the affected branch of the DAG (don't run downstream models on bad inputs).
   - If a single source is bad, exclude its downstream until fixed: build only the healthy selections.
   - Because **Bronze is immutable**, never edit raw data — correct downstream and document.
3. **Communicate.** Post in the Teams data channel. If dashboards are affected, tell the business owner(s) for those areas (see the business [Start Here → Who to ask](docs/business/README.md#who-to-ask)).
4. **Record.** Open a **DQ Incident Log** entry in the Hub: what, when detected, affected models, blast radius, status.
5. **Fix & verify.** Correct the cause, rebuild affected models (`--full-refresh` where needed), confirm reconciliation/business tests pass.
6. **Close.** Update the incident log with root cause and resolution. If the cause was a gap in testing, add a test so it can't recur silently.

---

## Rollback

If a deploy introduced a regression:

1. **Identify** the last-good state (commit / project version).
2. **Revert the code** on `main` (revert the PR) so source of truth is correct.
3. **Redeploy** the prior good version:
   ```
   -- Re-create the project from the known-good version, then rebuild
   CREATE OR REPLACE DBT PROJECT NS11MM_DW_PROD.SILVER.NS11MM_DBT
     FROM 'snow://workspace/USER$.PUBLIC."ns11mm-dbt"/versions/live';
   EXECUTE DBT PROJECT NS11MM_DW_PROD.SILVER.NS11MM_DBT ARGS = 'build';
   ```
4. **Full-refresh** any incremental models whose shape changed:
   ```
   EXECUTE DBT PROJECT NS11MM_DW_PROD.SILVER.NS11MM_DBT ARGS = 'build --full-refresh --select <model>+';
   ```
5. **Record** a Rollback Package entry in the Hub (what was rolled back, why, verification).
6. **Post-incident review** within 48 hours for anything that reached prod.

---

## Change Log procedure

Every **Tier 1** change (and any change that reaches prod) is recorded. Tier definitions are in [CONTRIBUTING → Change Gate Classification](CONTRIBUTING.md#change-gate-classification).

For a Tier 1 change:
1. Open a **Change Log** entry in the Hub (proposed change, files, risk, rollback plan).
2. Post 72-hour advance notice in the Teams data channel.
3. Get written approval from the infra owner (CODEOWNERS enforces the reviewer).
4. Deploy to **staging** first, validate, then prod.
5. Post-deploy validation, then a completion note in the Change Log + Teams.

**Emergency changes** (pipeline down, data stale): make the change, get verbal approval, merge with `[EMERGENCY]` prefix, file the Change Log entry within 24 hours, post-incident review within 48 hours.

---

## Useful commands

```
# What changed / dry run
dbt compile
dbt run-operation validate_before_deploy     # expect no FAIL results

# Targeted rebuilds
dbt build --select <model>+ --full-refresh
dbt build --select tag:daily

# Forecast model (run-operation)
dbt run-operation create_ticket_demand_forecast

# Verified queries (the Cortex Agent's certified answers)
dbt run-operation sync_verified_queries

# Agent observability (what was asked / generated SQL / results)
SELECT * FROM TABLE(SNOWFLAKE.LOCAL.GET_AI_OBSERVABILITY_EVENTS(
  'NS11MM_DW_PROD','GOLD','MUSEUM_OPERATIONS_AGENT','CORTEX AGENT'));
```

---

## Escalation

| Situation | Contact |
| --- | --- |
| Build/pipeline failure you can't resolve | Infra owner (Jeremy Myers) |
| Source system down or sending bad data | Source-system owner + infra owner |
| PII exposure or suspected data leak | Infra owner **immediately**; follow the Data Governance & Integrity Policy in the Hub |
| Stakeholder-facing dashboard wrong | Notify the area's business owner ([Who to ask](docs/business/README.md#who-to-ask)) + infra owner |

---

## Related

- [CONTRIBUTING](CONTRIBUTING.md) — change gates, deployment, VQR workflow
- [README](README.md) — architecture, lineage, testing strategy
- [Data Classification](docs/architecture/DATA_CLASSIFICATION.md) — PII handling
- [Documentation Map](docs/README.md) — everything else
- **Hub:** DQ Incident Log, Change Log, Rollback Package, Access Grant Matrix
