# Referential Integrity Tests

Singular data tests that validate foreign key relationships and seed-to-model consistency across Gold-layer models. These ensure dimension values exist and match reference data.

## Tests

| Test | Assertion |
|------|-----------|
| `assert_campaign_fk_integrity` | Campaign IDs in facts exist in dim_campaign |
| `assert_customer_segments_match_seed` | Customer segments match seed reference values |
| `assert_gold_daily_ops_no_orphan_dates` | Daily ops dates exist in dim_date |
| `assert_ltv_tiers_match_seed` | LTV tiers match seed reference values |
| `assert_member360_emails_exist_in_crm` | Member emails exist in CRM source |
| `assert_member360_no_orphan_contacts` | Member contacts link to valid CRM records |
| `assert_payment_methods_exist_in_dim` | Payment method IDs exist in dim_payment_method |
| `assert_payment_methods_match_seed` | Payment methods match seed reference values |
| `assert_products_exist_in_dim` | Product IDs exist in dim_product |
| `assert_scan_gates_exist_in_dim` | Gate IDs exist in dim_gate |
| `assert_ticket_types_exist_in_dim` | Ticket types exist in dim_ticket_type |
| `assert_ticket_types_match_seed` | Ticket types match seed reference values |

## When to Add Tests Here

- A new fact table references a dimension via FK
- A new dimension is populated from a seed file
- You need to ensure no orphan records exist across joins
