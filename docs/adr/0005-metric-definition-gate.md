# ADR-0005: Metric definitions must be approved before Gold models are built

- **Status:** Accepted
- **Date:** 2026
- **Deciders:** Jeremy Myers (VP, AI & Analytics), domain business owners
- **Supersedes:** —

## Context

The platform serves multiple domains (Attendance, Revenue & Fundraising, Membership, Donor Relations, Digital & Marketing, Operations) with different stakeholders. The legacy environment suffered from the classic problem of the same term meaning different things in different reports — two "membership counts," two "revenue" figures — eroding trust in the data. Gold-layer models and the metrics exposed to Power BI and the Cortex Agent are the institution's authoritative numbers, so an uncontrolled definition is an institutional risk, not just a technical one.

## Options considered

1. **Build first, define later** — fast, but reproduces the inconsistency problem and is hard to unwind once dashboards exist.
2. **Define and approve first (a gate)** — slower to start a metric, but guarantees a single agreed definition before it becomes "official."

## Decision

We will require that **every metric has a written, business-owner-approved definition before any Gold model implements it.** The approved definition is recorded (Metric Registry / Verified Query metadata) with an owner and approval date. Verified Queries (VQRs) consumed by the Cortex Agent must carry `approved_by` and `approved_date` before deployment; only `certified` queries are synced to the semantic views.

## Consequences

- **Positive:** One definition everywhere; dashboards and the AI assistant agree; trust in the numbers is preserved; the Metric Glossary is authoritative.
- **Negative / trade-offs:** Adding a metric takes an extra approval step; ad-hoc requests can't be satisfied instantly.
- **Follow-ups:** Maintain the Metric Registry (Hub) and the [Metric Glossary](../business/METRIC_GLOSSARY.md); the VQR workflow in CONTRIBUTING operationalizes this gate.

## References

- [CONTRIBUTING → Verified Query (VQR) Workflow](../../CONTRIBUTING.md#verified-query-vqr-workflow)
- [Business Start Here → I need a new metric](../business/README.md#i-need-a-new-metric-or-report)
- [Metric Glossary](../business/METRIC_GLOSSARY.md)
- Platform Hub: Metric Registry
