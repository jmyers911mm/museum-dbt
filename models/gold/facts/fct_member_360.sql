{{
    config(
        unique_key='contact_id',
        incremental_strategy='merge',
        on_schema_change='append_new_columns',
        cluster_by=['engagement_segment', 'computed_membership_status']
    )
}}

WITH crm AS (
    SELECT * FROM {{ ref('silver_sf_crm') }}
    {% if is_incremental() %}
    WHERE _loaded_at > (SELECT MAX(_loaded_at) FROM {{ this }})
    {% endif %}
),

ticket_purchases AS (
    SELECT
        customer_email,
        COUNT(DISTINCT transaction_id) AS ticket_purchase_count,
        SUM(total_amount) AS total_ticket_spend,
        MAX(transaction_date) AS last_ticket_purchase_date
    FROM {{ ref('silver_pos_tickets') }}
    WHERE customer_email IS NOT NULL
    GROUP BY 1
),

retail_purchases AS (
    SELECT
        customer_email,
        COUNT(DISTINCT transaction_id) AS retail_purchase_count,
        SUM(total_amount) AS total_retail_spend,
        MAX(transaction_date) AS last_retail_purchase_date
    FROM {{ ref('silver_pos_retail') }}
    WHERE customer_email IS NOT NULL
    GROUP BY 1
),

email_engagement AS (
    SELECT
        email_address,
        COUNT(CASE WHEN event_type = 'Open' THEN 1 END) AS email_opens,
        COUNT(CASE WHEN event_type = 'Click' THEN 1 END) AS email_clicks,
        MAX(CASE WHEN event_type = 'Open' THEN event_date END) AS last_email_open_date
    FROM {{ ref('silver_sf_marketing_cloud') }}
    GROUP BY 1
)

SELECT
    c.contact_id,
    c.full_name,
    c.email,
    c.membership_type,
    c.computed_membership_status,
    c.donor_tier,
    c.donation_total_ytd,
    c.days_since_last_visit,
    COALESCE(tp.ticket_purchase_count, 0) AS ticket_purchase_count,
    COALESCE(tp.total_ticket_spend, 0) AS total_ticket_spend,
    COALESCE(rp.retail_purchase_count, 0) AS retail_purchase_count,
    COALESCE(rp.total_retail_spend, 0) AS total_retail_spend,
    COALESCE(tp.total_ticket_spend, 0) + COALESCE(rp.total_retail_spend, 0) AS total_pos_spend,
    COALESCE(tp.total_ticket_spend, 0) + COALESCE(rp.total_retail_spend, 0) + COALESCE(c.donation_total_ytd, 0) AS total_lifetime_value,
    COALESCE(ee.email_opens, 0) AS email_opens,
    COALESCE(ee.email_clicks, 0) AS email_clicks,
    CASE
        WHEN c.computed_membership_status = 'Active'
             AND COALESCE(ee.email_clicks, 0) > 0
             AND c.days_since_last_visit <= 30
        THEN 'Highly Engaged'
        WHEN c.computed_membership_status = 'Active'
             AND c.days_since_last_visit <= 60
        THEN 'Engaged'
        WHEN c.days_since_last_visit <= 90
        THEN 'At Risk'
        ELSE 'Disengaged'
    END AS engagement_segment,
    GREATEST(
        COALESCE(tp.last_ticket_purchase_date, '1900-01-01'::DATE),
        COALESCE(rp.last_retail_purchase_date, '1900-01-01'::DATE),
        COALESCE(ee.last_email_open_date, '1900-01-01'::DATE),
        COALESCE(c.last_visit_date, '1900-01-01'::DATE)
    ) AS last_interaction_date,
    CURRENT_TIMESTAMP() AS _loaded_at
FROM crm c
LEFT JOIN ticket_purchases tp ON c.email = tp.customer_email
LEFT JOIN retail_purchases rp ON c.email = rp.customer_email
LEFT JOIN email_engagement ee ON c.email = ee.email_address
