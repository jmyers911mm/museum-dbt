
  
    

        create or replace transient table MUSEUM_DW_PROD.GOLD.fct_ticket_sales
        copy grants as
        (select * from (
              

WITH tickets AS (
    SELECT
        t.transaction_id,
        t.ticket_number,
        t.transaction_timestamp,
        t.transaction_date,
        t.ticket_type,
        t.visitor_category,
        t.quantity,
        t.unit_price,
        t.total_amount / NULLIF(t.quantity, 0) AS ticket_amount,
        t.total_amount,
        t.is_discounted,
        t.discount_amount,
        t.payment_method,
        t.payment_method_id,
        t.customer_email,
        t.customer_phone,
        t.has_email,
        t.has_phone
    FROM MUSEUM_DW_PROD.SILVER.silver_pos_tickets t
),

scans AS (
    SELECT
        ticket_transaction_id,
        scan_id,
        scan_timestamp,
        scan_date,
        gate_id,
        scan_result,
        is_valid_scan,
        visitor_count
    FROM MUSEUM_DW_PROD.SILVER.silver_ticket_scans
),

scan_summary AS (
    SELECT
        ticket_transaction_id,
        MIN(scan_timestamp) AS first_scan_timestamp,
        MAX(scan_timestamp) AS last_scan_timestamp,
        MIN(CASE WHEN is_valid_scan THEN gate_id END) AS entry_gate,
        MIN(scan_date) AS scan_date,
        COUNT(*) AS total_scan_attempts,
        SUM(CASE WHEN is_valid_scan THEN 1 ELSE 0 END) AS valid_scans,
        SUM(CASE WHEN NOT is_valid_scan THEN 1 ELSE 0 END) AS rejected_scans,
        SUM(CASE WHEN is_valid_scan THEN visitor_count ELSE 0 END) AS visitors_admitted
    FROM scans
    GROUP BY ticket_transaction_id
),

customer_lookup AS (
    SELECT
        customer_id,
        primary_email,
        primary_phone
    FROM MUSEUM_DW_PROD.GOLD.dim_customer
)

SELECT
    t.ticket_number,
    t.transaction_id,
    t.transaction_timestamp,
    t.transaction_date,
    s.scan_date,
    t.ticket_type,
    t.visitor_category,
    t.quantity,
    t.unit_price,
    t.ticket_amount,
    t.total_amount,
    t.is_discounted,
    t.discount_amount,
    t.payment_method,
    t.payment_method_id,
    t.customer_email,
    t.customer_phone,
    t.has_email,
    t.has_phone,
    COALESCE(ce.customer_id, cp.customer_id) AS customer_id,
    CASE WHEN s.ticket_transaction_id IS NOT NULL THEN TRUE ELSE FALSE END AS was_scanned,
    s.entry_gate,
    s.first_scan_timestamp,
    s.last_scan_timestamp,
    s.total_scan_attempts,
    s.valid_scans,
    s.rejected_scans,
    s.visitors_admitted,
    CASE
        WHEN s.ticket_transaction_id IS NULL THEN 'Unused'
        WHEN s.valid_scans > 0 THEN 'Used'
        ELSE 'Rejected'
    END AS utilization_status,
    DATEDIFF('minute', t.transaction_timestamp, s.first_scan_timestamp) AS minutes_purchase_to_entry,
    CURRENT_TIMESTAMP() AS _loaded_at
FROM tickets t
LEFT JOIN scan_summary s ON t.transaction_id = s.ticket_transaction_id
LEFT JOIN customer_lookup ce ON t.customer_email = ce.primary_email AND t.customer_email IS NOT NULL
LEFT JOIN customer_lookup cp ON t.customer_phone = cp.primary_phone AND t.customer_phone IS NOT NULL AND ce.customer_id IS NULL
              ) order by (transaction_date, ticket_type)
        );
      alter  table MUSEUM_DW_PROD.GOLD.fct_ticket_sales cluster by (transaction_date, ticket_type);
  