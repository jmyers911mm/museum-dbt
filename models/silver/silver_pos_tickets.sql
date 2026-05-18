SELECT
    transaction_id,
    transaction_timestamp,
    DATE_TRUNC('day', transaction_timestamp) AS transaction_date,
    ticket_type,
    CASE
        WHEN ticket_type LIKE '%Adult%' THEN 'Adult'
        WHEN ticket_type LIKE '%Child%' THEN 'Child'
        WHEN ticket_type LIKE '%Senior%' THEN 'Senior'
        WHEN ticket_type LIKE '%Member%' THEN 'Member'
        WHEN ticket_type LIKE '%School%' THEN 'School Group'
        WHEN ticket_type LIKE '%Family%' THEN 'Family'
        ELSE 'Other'
    END AS visitor_category,
    quantity,
    unit_price,
    total_amount,
    discount_code,
    discount_amount,
    CASE WHEN discount_amount > 0 THEN TRUE ELSE FALSE END AS is_discounted,
    payment_method,
    cashier_id,
    terminal_id,
    customer_email,
    CASE WHEN customer_email IS NOT NULL THEN TRUE ELSE FALSE END AS has_email,
    hashdiff,
    _loaded_at
FROM {{ ref('stg_pos_tickets') }}
