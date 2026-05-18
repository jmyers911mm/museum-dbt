SELECT campaign_id
FROM {{ ref('fct_campaign_performance') }}
WHERE open_rate_pct > 100
   OR bounce_rate_pct > 100
   OR unsubscribe_rate_pct > 100
   OR click_to_open_rate_pct > 100
