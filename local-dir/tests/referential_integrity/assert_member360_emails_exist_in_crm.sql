WITH gold_emails AS (
    SELECT DISTINCT email
    FROM {{ ref('fct_member_360') }}
    WHERE email IS NOT NULL
),
silver_emails AS (
    SELECT DISTINCT email
    FROM {{ ref('silver_sf_crm') }}
    WHERE email IS NOT NULL
)
SELECT g.email
FROM gold_emails g
LEFT JOIN silver_emails s ON g.email = s.email
WHERE s.email IS NULL
