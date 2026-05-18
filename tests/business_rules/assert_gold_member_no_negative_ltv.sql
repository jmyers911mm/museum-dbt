SELECT contact_id
FROM {{ ref('fct_member_360') }}
WHERE total_lifetime_value < 0
