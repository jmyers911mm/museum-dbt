WITH source AS (
    SELECT *
    FROM {{ ref('silver_pos_tickets') }}
)

SELECT DISTINCT
    ticket_type AS ticket_type_id,
    ticket_type AS ticket_type_name,
    visitor_category,
    unit_price AS standard_price,
    CASE
        WHEN unit_price = 0 THEN TRUE
        ELSE FALSE
    END AS is_free_admission,
    CASE
        WHEN visitor_category IN ('Child', 'Senior', 'Student') THEN 'Concession'
        WHEN visitor_category = 'Member' THEN 'Membership'
        WHEN visitor_category = 'School Group' THEN 'Group'
        WHEN visitor_category = 'Family' THEN 'Package'
        ELSE 'Standard'
    END AS pricing_tier,
    CASE
        WHEN ticket_type LIKE '%Special%' THEN TRUE
        ELSE FALSE
    END AS is_special_exhibition,
    CURRENT_TIMESTAMP() AS _loaded_at
FROM source
