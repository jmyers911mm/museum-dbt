# Generic Tests

Reusable test macros that can be applied to any model via `schema.yml` declarations. These extend dbt's built-in test framework with museum-specific data quality checks.

## Macros

| Macro | Purpose |
|-------|---------|
| `data_quality_tests.sql` | 8 generic tests for data quality monitoring (see below) |
| `generate_hashdiff.sql` | Generates MD5 hashdiff column from a list of columns with null-safe concatenation |
| `test_hashdiff_integrity.sql` | Validates hashdiff columns are deterministic and collision-free |

## Data Quality Tests

| Test | Parameters | Purpose |
|------|-----------|---------|
| `z_score_outlier` | `column_name`, `max_zscore` (default 3) | Flags values > N standard deviations from mean |
| `positive_value` | `column_name` | Fails if any negative values exist |
| `value_between` | `column_name`, `min_value`, `max_value` | Validates column stays within bounds |
| `null_rate_threshold` | `column_name`, `max_null_pct` (default 50) | Fails if null percentage exceeds threshold |
| `late_arriving_data` | `timestamp_column`, `max_lag_hours` (default 72) | Detects records loaded recently but timestamped beyond max lag |
| `daily_volume_bounds` | `date_column`, `min_rows_per_day`, `max_rows_per_day` | Validates daily row counts stay within bounds |
| `cardinality_change` | `column_name`, `min_expected`, `max_expected` | Alerts if distinct value count falls outside range |
| `distribution_shift` | `column_name`, `value`, `min_pct`, `max_pct` | Detects when a value's frequency drifts outside acceptable range |

## Usage

Generic tests are referenced in `schema.yml` files:

```yaml
columns:
  - name: total_amount
    tests:
      - positive_value
      - z_score_outlier:
          max_zscore: 4
      - value_between:
          min_value: 0
          max_value: 10000
```

## When to Add Macros Here

- The test logic applies to multiple models/columns
- You need parameterized assertions (e.g., `min_value`, `max_value`)
- The test complements (not duplicates) dbt built-in tests
