WITH gold_campaigns AS (
    SELECT DISTINCT campaign_id
    FROM {{ ref('fct_campaign_performance') }}
    WHERE campaign_id IS NOT NULL
),
dim_campaigns AS (
    SELECT DISTINCT campaign_id
    FROM {{ ref('dim_campaign') }}
)
SELECT g.campaign_id
FROM gold_campaigns g
LEFT JOIN dim_campaigns d ON g.campaign_id = d.campaign_id
WHERE d.campaign_id IS NULL
