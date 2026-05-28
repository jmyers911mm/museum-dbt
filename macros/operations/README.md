# Operations Macros

Utility macros for operational tasks such as schema management, forecasting, and data synchronization.

## Macros

| Macro | Purpose |
|-------|---------|
| `generate_schema_name.sql` | Custom schema naming strategy (overrides dbt default to route models to correct schemas) |
| `create_ticket_demand_forecast.sql` | Run-operation macro to generate ticket demand forecasts |
| `sync_verified_queries.sql` | Syncs verified queries for semantic view / Cortex Analyst integration |

## Usage

These macros are invoked via `dbt run-operation`:

```bash
dbt run-operation create_ticket_demand_forecast
dbt run-operation sync_verified_queries
```

The `generate_schema_name` macro is called automatically by dbt during model materialization.

## When to Add Macros Here

- The macro performs an operational task (not a test)
- It's invoked via `run-operation` or overrides dbt behavior
- It does not belong in a model file
