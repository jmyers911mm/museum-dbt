SELECT *
FROM SEMANTIC_VIEW(museum_dw_prod.gold.sv_donor_retention
  METRICS avg_churn_rate, total_cohort_size
  DIMENSIONS retention.acquisition_method)
