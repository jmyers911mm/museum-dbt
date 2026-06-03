# ADR-0006: Tiered change management for the data platform

- **Status:** Accepted
- **Date:** 2026
- **Deciders:** Jeremy Myers (VP, AI & Analytics), Michael Cartier (CIO)
- **Supersedes:** —

## Context

A small team maintains a production platform that the whole institution relies on. Not all changes carry equal risk: editing one model's SQL is low-risk and reversible; changing `dbt_project.yml`, CI config, schema-routing macros, or access controls can affect every model and every consumer at once. Treating all changes the same would either slow the team down (heavy process on trivial changes) or expose prod to unreviewed high-blast-radius changes. We needed a proportionate process.

## Options considered

1. **Uniform process for all changes** — simple to state, but either too heavy or too light somewhere.
2. **Tiered process keyed to blast radius** — match the ceremony (notice, approval, staging) to the risk of the specific change.

## Decision

We will classify changes into tiers and apply controls proportionate to risk:

- **Tier 1 — Infrastructure / high blast radius** (e.g., `dbt_project.yml`, `profiles.yml`, CI workflow, schema-routing and circuit-breaker macros, developer-setup script, `CODEOWNERS`): require a Change Log entry, **72-hour advance notice**, written approval from the infra owner, and **deploy-to-staging-first**.
- **Tier 2 — Model changes** (model SQL, `schema.yml`, tests): standard PR workflow — feature branch → dev build → PR → CI → merge → deploy.
- **Emergency** (pipeline down / data stale): make the change, get verbal approval, merge with an `[EMERGENCY]` prefix, file the Change Log entry within 24 hours, and hold a post-incident review within 48 hours.

`CODEOWNERS` enforces that the right reviewer signs off per file path.

## Consequences

- **Positive:** High-risk changes get scrutiny and a staging gate; routine changes stay fast; there's an audit trail (Change Log) for anything that reaches prod.
- **Negative / trade-offs:** Tier 1 changes have a deliberate delay; the team must keep the Change Log current.
- **Follow-ups:** Keep the Tier 1 file list in CONTRIBUTING in sync with reality; maintain Change Log / Rollback Package records in the Hub.

## References

- [CONTRIBUTING → Change Gate Classification](../../CONTRIBUTING.md#change-gate-classification)
- [RUNBOOK → Change Log procedure](../../RUNBOOK.md#change-log-procedure)
- `CODEOWNERS`
- Platform Hub: Change Log, Rollback Package
