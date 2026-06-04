# ADR-0001: Data warehouse — Snowflake over Microsoft Fabric

- **Status:** Accepted
- **Date:** 2026
- **Deciders:** Jeremy Myers (VP, AI & Analytics), Michael Cartier (CIO)
- **Supersedes:** —

## Context

The data platform modernization replaces legacy Pentaho ETL and SSRS reporting. We needed to select the cloud data warehouse that would serve as the platform's foundation. A Microsoft Fabric proof-of-concept was evaluated against Snowflake. As a nonprofit, total cost of ownership, operational simplicity for a small team, and a clean separation of compute and storage were primary concerns, alongside support for the medallion (Bronze/Silver/Gold) architecture, dbt, and Power BI.

## Options considered

1. **Microsoft Fabric (POC)** — tight Power BI integration and Microsoft-ecosystem alignment, but the POC surfaced concerns around cost predictability, operational fit, and maturity for our use case.
2. **Snowflake** — mature separation of compute/storage, predictable warehouse sizing, strong dbt support, native semantic views and Cortex, and straightforward role-based access control.

## Decision

We will use **Snowflake** as the platform data warehouse. The Microsoft Fabric POC is rejected. The warehouse is provisioned and governed via Terraform; environments are `NS11MM_DW_DEV` (per-developer), `NS11MM_DW_STAGING`, and `NS11MM_DW_PROD`, each with `BRONZE / SILVER / GOLD / ML_FEATURES` schemas.

## Consequences

- **Positive:** Clean medallion implementation; dbt Core runs natively; per-developer database isolation; native semantic views and a Cortex Agent for self-service; predictable, sizable warehouses (`DBT_DEV_WH`, `DBT_PROD_WH`).
- **Negative / trade-offs:** Power BI cannot natively consume Snowflake's (or dbt's) semantic layer, which forces some metric logic to be expressed in the Gold layer and/or DAX. This semantic-layer bridge remains an open architectural question tracked separately.
- **Follow-ups:** Terraform IaC for warehouses/roles/grants; the semantic-layer strategy is its own ongoing decision.

## References

- [README → Architecture](../../README.md#architecture)
- `terraform/` (infrastructure as code)
- Platform Hub: initiative records, semantic-layer evaluation notes
