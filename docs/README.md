# Documentation Map

This is the front door for **all** documentation about the Museum Data Platform. It exists so that anyone — a board member, a marketing manager, an analyst, or a data engineer — can find what they need in under a minute.

If you only read one thing, read the row in the table below that matches who you are.

---

## Start here — pick your role

| I am a…​ | Start here | What you'll find |
| --- | --- | --- |
| **Business user / stakeholder** (Development, Membership, Marketing, Operations, Education, Finance) | [Business Start Here](business/README.md) | What the platform does, which dashboard answers your question, what each metric means, and who to ask |
| **Analyst / report builder** | [Business Start Here](business/README.md) → then [Metric Glossary](business/METRIC_GLOSSARY.md) | Certified metric definitions, the report finder, and the semantic layer that powers self-service |
| **New team member (data team)** | [Onboarding](ONBOARDING.md) | Day-1 setup: clone, configure your workspace, run your first build |
| **Data engineer / contributor** | [Main README](../README.md) → [CONTRIBUTING](../CONTRIBUTING.md) | Architecture, lineage, models, tests, and the full contribution workflow |
| **On-call / responding to an incident** | [RUNBOOK](../RUNBOOK.md) | Scheduled jobs, freshness/circuit-breaker behavior, quarantine steps, rollback, escalation |
| **Anyone making an architecture or governance decision** | [ADR Log](adr/README.md) | Why the platform is built the way it is, decision by decision |

---

## The two homes for documentation

Documentation lives in **two** places. This map links across both so you never have to guess.

### 1. This GitHub repository (`jmyers911mm/ns11mm-dbt`)
The **technical source of truth** — the dbt project, its tests, lineage, and the docs that engineers and analysts need to build and maintain it.

| Document | Audience | Purpose |
| --- | --- | --- |
| [README](../README.md) | Engineers, analysts | Architecture, data layers, models, lineage, testing strategy |
| [CONTRIBUTING](../CONTRIBUTING.md) | Contributors | Branch strategy, ownership zones, change gates, VQR workflow |
| [ONBOARDING](ONBOARDING.md) | New team members | Linear day-1 setup checklist |
| [RUNBOOK](../RUNBOOK.md) | On-call, operators | Operational procedures, incidents, rollback |
| [SQL Style Guide](SQL_STYLE_GUIDE.md) | Contributors | Naming, layering, and formatting conventions |
| [Data Classification](DATA_CLASSIFICATION.md) | Everyone touching data | PII handling, classification tiers, access rules |
| [ADR Log](adr/README.md) | Decision-makers | Architecture Decision Records |
| [Business Start Here](business/README.md) | Business users | Plain-language entry point |
| [Metric Glossary](business/METRIC_GLOSSARY.md) | Business users, analysts | What every metric means, in plain English |
| [CHANGELOG](../CHANGELOG.md) | Everyone | Release history with model/test counts |

#### Architecture & technical reference (`docs/architecture/`)
Deep-dive diagrams and plans for engineers and architects.

| Document | Audience | Purpose |
| --- | --- | --- |
| [Architecture Flow](architecture/ARCHITECTURE_FLOW.md) | Engineers, architects | End-to-end data flow Bronze → Silver → Gold → ML → semantic → Power BI, with test gates |
| [Source Integration](architecture/SOURCE_INTEGRATION.md) | Engineers, architects | Every source system: real vendor product, API/extraction method, auth model |
| [Test Orchestration](architecture/TEST_ORCHESTRATION.md) | Engineers, on-call | Source clusters, freshness SLAs, test triggers, and alert routing |
| [Snowflake Settings](architecture/SNOWFLAKE_SETTINGS.md) | Engineers, admins | *(to be added)* Account/warehouse/role/session configuration |
| [Project Map](architecture/PROJECT_MAP.md) | Engineers | *(to be added)* Walkthrough of the dbt project folder structure |
| [Usage Audit](architecture/USAGE_AUDIT.md) | Engineers, admins | *(to be added)* Compute/credit usage and Cortex agent usage auditing |

### 2. The Platform Hub (internal portal)
The **operational and governance source of truth** — the living registries and logs that change frequently and serve the whole institution. The Hub holds the authoritative versions of:

- **Metric Registry** — the certified catalog of every metric and its owner
- **Report Registry** — every published dashboard and what it covers
- **DQ Incident Log** — data quality incidents, status, and resolution
- **Change Log** — every Tier 1 change and its approval
- **Initiative Dashboard** — modernization roadmap and milestones
- **Training Guides** — how-to material for each tool
- **Governance documents** — Data Governance & Integrity Policy, AI Charter, Data Charter, Access Grant Matrix

> **Rule of thumb:** if it's *code or a code-level decision*, it lives in this repo. If it's a *living registry, log, or institutional policy*, it lives in the Hub. This map links to both.

---

## How the documentation stays current

- **Repo docs** are version-controlled. Changes go through the normal PR process (see [CONTRIBUTING](../CONTRIBUTING.md)). Update the relevant doc in the same PR as the code change it describes.
- **The CHANGELOG** is updated on every release.
- **The Hub registries** are updated by the data team as metrics, reports, and incidents change.
- **ADRs are immutable once accepted** — you supersede an old decision with a new ADR rather than editing history (see the [ADR Log](adr/README.md)).

If you find a doc that's wrong, out of date, or missing, open an issue or tag the data team — documentation gaps are treated like bugs.