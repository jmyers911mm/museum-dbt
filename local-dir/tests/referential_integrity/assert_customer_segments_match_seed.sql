-- Validates that all customer segments in dim_customer match ref_customer_segments seed
SELECT DISTINCT c.customer_segment
FROM {{ ref('dim_customer') }} c
LEFT JOIN {{ ref('ref_customer_segments') }} r ON c.customer_segment = r.customer_segment
WHERE r.customer_segment IS NULL
  AND c.customer_segment IS NOT NULL
