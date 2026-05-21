
  
    

        create or replace transient table MUSEUM_DW_PROD.ML_FEATURES.ml_ticket_no_show_features
         as
        (

WITH tickets AS (
    SELECT
        ticket_number,
        transaction_id,
        transaction_date,
        ticket_type,
        visitor_category,
        quantity,
        total_amount,
        is_discounted,
        discount_amount,
        payment_method_id,
        customer_id,
        was_scanned,
        utilization_status,
        minutes_purchase_to_entry,
        EXTRACT(HOUR FROM transaction_timestamp) AS purchase_hour,
        EXTRACT(DOW FROM transaction_date) AS day_of_week_num,
        CASE WHEN EXTRACT(DOW FROM transaction_date) IN (0, 6) THEN 1 ELSE 0 END AS is_weekend
    FROM MUSEUM_DW_PROD.GOLD.fct_ticket_sales
),

customer_history AS (
    SELECT
        customer_id,
        COUNT(*) AS prior_ticket_count,
        SUM(CASE WHEN was_scanned THEN 0 ELSE 1 END) AS prior_no_shows,
        DIV0(SUM(CASE WHEN was_scanned THEN 0 ELSE 1 END), COUNT(*)) AS historical_no_show_rate
    FROM MUSEUM_DW_PROD.GOLD.fct_ticket_sales
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
),

ticket_type_stats AS (
    SELECT
        ticket_type,
        AVG(CASE WHEN NOT was_scanned THEN 1.0 ELSE 0.0 END) AS type_no_show_rate,
        AVG(minutes_purchase_to_entry) AS type_avg_lead_time
    FROM MUSEUM_DW_PROD.GOLD.fct_ticket_sales
    GROUP BY ticket_type
)

SELECT
    t.ticket_number,
    t.transaction_id,
    t.transaction_date,
    t.ticket_type,
    t.visitor_category,
    t.quantity,
    t.total_amount,
    t.is_discounted,
    t.payment_method_id,
    t.customer_id,
    t.purchase_hour,
    t.day_of_week_num,
    t.is_weekend,
    CASE WHEN t.customer_id IS NULL THEN 1 ELSE 0 END AS is_anonymous,
    COALESCE(ch.prior_ticket_count, 0) AS customer_prior_tickets,
    COALESCE(ch.prior_no_shows, 0) AS customer_prior_no_shows,
    COALESCE(ch.historical_no_show_rate, 0) AS customer_no_show_rate,
    COALESCE(ts.type_no_show_rate, 0) AS ticket_type_no_show_rate,
    COALESCE(ts.type_avg_lead_time, 0) AS ticket_type_avg_lead_time,
    CASE WHEN t.utilization_status = 'Unused' THEN 1 ELSE 0 END AS is_no_show
FROM tickets t
LEFT JOIN customer_history ch ON t.customer_id = ch.customer_id
LEFT JOIN ticket_type_stats ts ON t.ticket_type = ts.ticket_type
        );
      
  