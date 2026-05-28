# ML Features

Feature engineering models that prepare data for machine learning pipelines. Materialized as **tables** in the `ML_FEATURES` schema with grants to `ML_ROLE`.

## Responsibilities

- Aggregate and transform Gold-layer data into ML-ready feature sets
- Compute time-windowed aggregations, ratios, and categorical encodings
- Maintain consistent grain suitable for model training
- Tag features with descriptive names for model registry integration

## Models

| Model | Use Case |
|-------|----------|
| `ml_ticket_demand_features` | Predict daily ticket demand by type |
| `ml_daily_visitor_features` | Forecast daily visitor counts |
| `ml_visitor_forecast_training` | Training dataset for visitor forecasting |
| `ml_dynamic_pricing_features` | Dynamic ticket pricing optimization |
| `ml_ticket_no_show_features` | Predict ticket no-shows |
| `ml_donor_churn_features` | Donor churn prediction |
| `ml_donor_upgrade_propensity_features` | Donor upgrade propensity scoring |
| `ml_member_churn_features` | Membership churn prediction |
| `ml_retail_cross_sell_features` | Retail cross-sell recommendations |
| `ml_campaign_response_features` | Campaign response prediction |
| `ml_email_send_time_features` | Optimal email send time prediction |
| `ml_marketing_attribution_features` | Marketing attribution modeling |
| `ml_ad_budget_optimization_features` | Ad budget allocation optimization |
| `ml_ad_creative_features` | Ad creative performance prediction |

## Conventions

- File naming: `ml_<use_case>_features.sql`
- All models materialized as transient tables
- Tagged `['daily', 'non-critical']`
- Schema tests defined in `schema.yml`
