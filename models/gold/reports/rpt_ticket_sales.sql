SELECT
    ts.ticket_number,
    ts.transaction_id,
    ts.transaction_date,
    dd_txn.day_name AS purchase_day_name,
    dd_txn.month_name AS purchase_month,
    dd_txn.fiscal_year AS purchase_fiscal_year,
    dd_txn.is_weekend AS purchased_on_weekend,
    ts.scan_date,
    dd_scan.day_name AS scan_day_name,
    dd_scan.is_weekend AS scanned_on_weekend,
    ts.ticket_type,
    dt.ticket_type_name,
    dt.visitor_category AS ticket_visitor_category,
    dt.standard_price AS ticket_standard_price,
    dt.pricing_tier,
    dt.is_free_admission,
    dt.is_special_exhibition,
    ts.quantity,
    ts.unit_price,
    ts.total_amount,
    ts.ticket_amount,
    ts.discount_amount,
    ts.is_discounted,
    ts.payment_method_id,
    pm.payment_method_name,
    pm.payment_category,
    ts.entry_gate,
    dg.gate_name,
    dg.location AS gate_location,
    dg.is_members_only AS entered_members_gate,
    ts.customer_id,
    c.full_name AS customer_name,
    c.customer_segment,
    c.membership_type,
    ts.was_scanned,
    ts.utilization_status,
    ts.minutes_purchase_to_entry,
    ts.visitors_admitted
FROM {{ ref('fct_ticket_sales') }} ts
LEFT JOIN {{ ref('dim_date') }} dd_txn ON ts.transaction_date::DATE = dd_txn.date_day
LEFT JOIN {{ ref('dim_date') }} dd_scan ON ts.scan_date::DATE = dd_scan.date_day
LEFT JOIN {{ ref('dim_ticket_type') }} dt ON ts.ticket_type = dt.ticket_type_id
LEFT JOIN {{ ref('dim_payment_method') }} pm ON ts.payment_method_id = pm.payment_method_id
LEFT JOIN {{ ref('dim_gate') }} dg ON ts.entry_gate = dg.gate_id
LEFT JOIN {{ ref('dim_customer') }} c ON ts.customer_id = c.customer_id
