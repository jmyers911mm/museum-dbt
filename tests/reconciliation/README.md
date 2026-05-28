# Reconciliation Tests

Singular data tests that verify row counts and aggregate values reconcile between layers (Bronze → Silver → Gold). These serve as circuit breakers to catch data loss or duplication during transformation.

## Tests

| Test | Assertion |
|------|-----------|
| `assert_silver_bronze_ticket_count_match` | Silver ticket count matches Bronze source |
| `assert_silver_bronze_retail_count_match` | Silver retail count matches Bronze source |
| `assert_silver_bronze_scan_count_match` | Silver scan count matches Bronze source |
| `assert_ticket_revenue_reconciles` | Gold ticket revenue reconciles with Silver |
| `assert_retail_revenue_reconciles` | Gold retail revenue reconciles with Silver |
| `assert_visitor_count_reconciles` | Gold visitor count reconciles with Silver scans |

## When to Add Tests Here

- You are adding a new layer-to-layer transformation
- You need to ensure aggregations sum correctly across grains
- Data loss or duplication would create material reporting errors
