{{
    config(
        materialized='table',
        cluster_by=['customer_id']
    )
}}

WITH identifiers AS (
    SELECT
        identifier_type,
        LOWER(TRIM(identifier_value)) AS identifier_value,
        source_system,
        source_id
    FROM {{ source('bronze', 'raw_customer_identifiers') }}
    WHERE identifier_value IS NOT NULL
),

emails AS (
    SELECT DISTINCT identifier_value AS email
    FROM identifiers WHERE identifier_type = 'EMAIL'
),

phones AS (
    SELECT DISTINCT identifier_value AS phone
    FROM identifiers WHERE identifier_type = 'PHONE'
),

email_phone_pairs AS (
    SELECT DISTINCT
        e.identifier_value AS email,
        p.identifier_value AS phone
    FROM identifiers e
    INNER JOIN identifiers p
        ON e.source_system = p.source_system
        AND e.source_id = p.source_id
    WHERE e.identifier_type = 'EMAIL'
      AND p.identifier_type = 'PHONE'
),

customer_clusters AS (
    SELECT
        email,
        phone,
        MIN(email) OVER (PARTITION BY phone) AS cluster_email_by_phone,
        MIN(phone) OVER (PARTITION BY email) AS cluster_phone_by_email
    FROM email_phone_pairs
),

resolved AS (
    SELECT
        COALESCE(email, cluster_email_by_phone) AS resolved_email,
        COALESCE(phone, cluster_phone_by_email) AS resolved_phone,
        MD5(COALESCE(
            MIN(email) OVER (PARTITION BY COALESCE(phone, cluster_phone_by_email)),
            email,
            phone
        )) AS customer_id
    FROM customer_clusters
),

customer_keys AS (
    SELECT DISTINCT
        customer_id,
        resolved_email AS email,
        resolved_phone AS phone
    FROM resolved
    UNION
    SELECT DISTINCT
        MD5(identifier_value) AS customer_id,
        CASE WHEN identifier_type = 'EMAIL' THEN identifier_value END AS email,
        CASE WHEN identifier_type = 'PHONE' THEN identifier_value END AS phone
    FROM identifiers
    WHERE identifier_value NOT IN (
        SELECT email FROM email_phone_pairs
        UNION ALL
        SELECT phone FROM email_phone_pairs
    )
),

grouped AS (
    SELECT
        customer_id,
        ARRAY_AGG(DISTINCT email) WITHIN GROUP (ORDER BY email) AS emails,
        ARRAY_AGG(DISTINCT phone) WITHIN GROUP (ORDER BY phone) AS phones,
        MIN(email) AS primary_email,
        MIN(phone) AS primary_phone
    FROM customer_keys
    WHERE email IS NOT NULL OR phone IS NOT NULL
    GROUP BY customer_id
),

crm_match AS (
    SELECT
        g.customer_id,
        g.primary_email,
        g.primary_phone,
        g.emails,
        g.phones,
        c.contact_id AS crm_contact_id,
        c.first_name,
        c.last_name,
        TRIM(CONCAT(COALESCE(c.first_name, ''), ' ', COALESCE(c.last_name, ''))) AS full_name,
        c.membership_type,
        c.membership_status,
        c.membership_start_date,
        c.membership_end_date,
        c.donation_total_ytd,
        c.preferred_contact_method,
        c.opt_in_email
    FROM grouped g
    LEFT JOIN {{ source('bronze', 'raw_sf_crm') }} c
        ON LOWER(TRIM(c.email)) = g.primary_email
)

SELECT
    customer_id,
    crm_contact_id,
    full_name,
    primary_email,
    primary_phone,
    emails,
    phones,
    ARRAY_SIZE(emails) AS email_count,
    ARRAY_SIZE(phones) AS phone_count,
    membership_type,
    membership_status,
    membership_start_date,
    membership_end_date,
    donation_total_ytd,
    preferred_contact_method,
    opt_in_email,
    CASE
        WHEN crm_contact_id IS NOT NULL THEN 'Known Member'
        WHEN primary_email IS NOT NULL THEN 'Identified Visitor'
        ELSE 'Anonymous'
    END AS customer_segment,
    CURRENT_TIMESTAMP() AS _loaded_at
FROM crm_match
