WITH member360_contacts AS (
    SELECT DISTINCT contact_id
    FROM {{ ref('fct_member_360') }}
),
silver_contacts AS (
    SELECT DISTINCT contact_id
    FROM {{ ref('silver_sf_crm') }}
)
SELECT g.contact_id
FROM member360_contacts g
LEFT JOIN silver_contacts s ON g.contact_id = s.contact_id
WHERE s.contact_id IS NULL
