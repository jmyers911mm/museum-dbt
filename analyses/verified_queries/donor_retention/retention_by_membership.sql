SELECT *
FROM SEMANTIC_VIEW(ns11mm_dw_prod.gold.sv_donor_retention
  METRICS avg_retention_rate, total_retained
  DIMENSIONS retention.membership_type, retention.months_since_acquisition)
