# Generic Tests

Reusable test macros that can be applied to any model via `schema.yml` declarations. These extend dbt's built-in test framework with museum-specific data quality checks.

## Macros

| Macro | Purpose |
|-------|---------|
| `data_quality_tests.sql` | Custom generic tests for data quality (e.g., non-negative values, valid ranges, freshness checks) |
| `generate_hashdiff.sql` | Generates a hash diff column for SCD detection |
| `test_hashdiff_integrity.sql` | Validates hashdiff columns are deterministic and collision-free |

## Usage

Generic tests are referenced in `schema.yml` files:

```yaml
columns:
  - name: total_amount
    tests:
      - custom_test_name:
          param: value
```

## When to Add Macros Here

- The test logic applies to multiple models/columns
- You need parameterized assertions (e.g., `min_value`, `max_value`)
- The test complements (not duplicates) dbt built-in tests
