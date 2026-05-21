{{
    config(
        tags=['intraday', 'critical']
    )
}}

SELECT
    transaction_id,
    transaction_timestamp,
    entry_time_purchased,
    DATE_TRUNC('day', entry_time_purchased)::DATE AS entry_date,
    entry_time_purchased::TIME AS entry_window_start,
    TIMEADD('minute', 30, entry_time_purchased::TIME) AS entry_window_end,
    ticket_type,
    CASE ticket_type
        WHEN 'General Admission Adult' THEN 'Museum General Admission'
        WHEN 'General Admission Senior' THEN 'Museum General Admission'
        WHEN 'General Admission Child' THEN 'Museum General Admission'
        WHEN 'Free Member Entry' THEN 'Museum Free Admission'
        WHEN 'Member Guest' THEN 'Museum Free Admission'
        WHEN 'Family Pack (4)' THEN 'Museum General Admission'
        WHEN 'School Group' THEN 'Museum Admission Special'
        WHEN 'Special Exhibition' THEN 'Museum Admission Special'
        ELSE 'Museum General Admission'
    END AS mapped_ticket_type,
    quantity,
    unit_price,
    total_amount,
    discount_code,
    discount_amount,
    payment_method,
    cashier_id,
    terminal_id,
    LOWER(TRIM(customer_email)) AS customer_email,
    TRIM(customer_phone) AS customer_phone,
    ticket_number,
    payment_method_id,
    _loaded_at,
    {{ generate_hashdiff([
        'ticket_type', 'entry_time_purchased', 'quantity', 'unit_price', 'total_amount',
        'discount_code', 'discount_amount', 'payment_method',
        'cashier_id', 'terminal_id', 'customer_email'
    ]) }} AS hashdiff
FROM {{ source('bronze', 'raw_pos_tickets') }}
