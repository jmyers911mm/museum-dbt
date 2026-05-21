SELECT *
FROM SEMANTIC_VIEW(museum_dw_prod.gold.sv_donor_retention
  METRICS avg_survival_rate, total_original_cohort, total_surviving
  DIMENSIONS survival.cohort_month, survival.cohort_health)
