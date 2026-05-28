# Business Rules Tests

Singular data tests that validate domain-specific business invariants on Gold-layer models. These catch logical errors that schema-level tests cannot detect.

## Tests

| Test | Assertion |
|------|-----------|
| `assert_gold_campaign_rates_valid` | Campaign open/click/bounce rates are between 0–100% |
| `assert_gold_daily_ops_no_negative_revenue` | Daily operations revenue is never negative |
| `assert_gold_member_no_negative_ltv` | Member lifetime value is never negative |
| `assert_gold_ops_covers_all_scan_dates` | Every scan date has a corresponding daily operations record |

## When to Add Tests Here

- The rule enforces a business constraint (not a schema/FK constraint)
- The assertion spans multiple columns or requires calculation
- Violations indicate a logic error in upstream transformations, not bad source data
