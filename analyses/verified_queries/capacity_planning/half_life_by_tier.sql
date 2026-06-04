SELECT *
FROM SEMANTIC_VIEW(ns11mm_dw_prod.gold.sv_donor_retention
  METRICS avg_survival_rate
  DIMENSIONS survival.donor_tier, survival.months_since_acquisition
  WHERE survival.is_half_life_month = TRUE)
