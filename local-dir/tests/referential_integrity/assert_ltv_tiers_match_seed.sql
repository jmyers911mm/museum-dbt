-- Validates that all LTV tiers in rpt_customer_ltv match ref_ltv_tiers seed
SELECT DISTINCT l.ltv_tier
FROM {{ ref('rpt_customer_ltv') }} l
LEFT JOIN {{ ref('ref_ltv_tiers') }} r ON l.ltv_tier = r.ltv_tier
WHERE r.ltv_tier IS NULL
  AND l.ltv_tier IS NOT NULL
