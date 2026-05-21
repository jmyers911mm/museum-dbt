# Verified Queries

This folder contains all certified verified queries (VQRs) for Cortex Analyst semantic views.

## Folder Structure

```
analyses/verified_queries/
├── revenue_operations/     # Revenue trending, fiscal reporting, payment analysis
├── ticket_sales/           # Ticket pricing, AOV, utilization, discounts
├── visitor_experience/     # Hourly traffic, gate patterns
├── retail/                 # Product performance, category analysis
├── membership/             # Customer LTV, segments, membership programs
├── campaigns/              # Email marketing performance
├── donor_retention/        # Cohort retention, survival curves, churn
└── capacity_planning/      # Availability, demand benchmarks, sold-out slots
```

## File Conventions

Each domain folder contains:
- `_verified_queries.yml` — Metadata including question, owner, ADR reference, tags, and Power BI dataset mapping
- `*.sql` — The verified query SQL using `SEMANTIC_VIEW()` syntax

## YAML Schema

```yaml
verified_queries:
  - name: query_name              # Unique ID (matches SQL filename without .sql)
    description: >                # Business context and usage
    file: query_name.sql          # SQL file reference
    semantic_view: DB.SCHEMA.VIEW # Target semantic view FQN
    question: "..."               # Natural language question this answers
    stakeholder_owner: Name       # Business owner
    adm_reference: ADR-XXX-XX    # Architecture decision record reference
    approved_by: username         # Approver
    approved_date: "YYYY-MM-DD"  # Approval date
    tags: [domain, certified]     # Searchable tags
    power_bi_datasets:            # Which PBI datasets use this
      - Dataset Name
```

## Governance

- All VQRs require `approved_by` and `approved_date` before deployment
- VQRs tagged `certified` are synced to semantic views on deploy
- VQRs tagged `action_required` trigger proactive alerts
- ADR references link to architecture decision records for audit trail

## Sync to Semantic Views

Run `dbt run-operation sync_verified_queries` to deploy all certified VQRs to their target semantic views. This reads the YAML files and rebuilds the `AI_VERIFIED_QUERIES` section of each semantic view.
