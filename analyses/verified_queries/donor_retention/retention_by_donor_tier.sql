SELECT *
FROM SEMANTIC_VIEW(museum_dw_prod.gold.sv_donor_retention
  METRICS avg_retention_rate, total_cohort_size
  DIMENSIONS retention.donor_tier, retention.months_since_acquisition)
