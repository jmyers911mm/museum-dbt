WITH ga_sessions AS (
    SELECT
        session_id,
        session_date,
        user_pseudo_id,
        source,
        medium,
        channel_grouping,
        page_category,
        is_conversion
    FROM {{ ref('silver_google_analytics') }}
    WHERE is_conversion = TRUE
),

customer_emails AS (
    SELECT
        customer_id,
        primary_email,
        customer_segment,
        membership_type
    FROM {{ ref('dim_customer') }}
    WHERE primary_email IS NOT NULL
),

ticket_buyers AS (
    SELECT DISTINCT
        transaction_date,
        customer_id
    FROM {{ ref('fct_ticket_sales') }}
    WHERE customer_id IS NOT NULL
)

SELECT
    ga.session_id,
    ga.session_date,
    ga.user_pseudo_id,
    ga.channel_grouping,
    ga.source,
    ga.medium,
    ga.page_category,
    tb.customer_id,
    ce.customer_segment,
    ce.membership_type,
    CASE WHEN tb.customer_id IS NOT NULL THEN TRUE ELSE FALSE END AS matched_to_customer
FROM ga_sessions ga
LEFT JOIN ticket_buyers tb ON ga.session_date = tb.transaction_date
LEFT JOIN customer_emails ce ON tb.customer_id = ce.customer_id
