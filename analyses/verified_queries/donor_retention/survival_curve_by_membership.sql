SELECT *
FROM SEMANTIC_VIEW(museum_dw_prod.gold.sv_donor_retention
  METRICS avg_survival_rate
  DIMENSIONS survival.membership_type, survival.months_since_acquisition)
