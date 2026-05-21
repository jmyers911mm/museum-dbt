
  
    

        create or replace transient table MUSEUM_DW_PROD.GOLD.rpt_member_360
        copy grants as
        (SELECT
    c.customer_id,
    c.crm_contact_id,
    c.full_name,
    c.primary_email,
    c.primary_phone,
    c.email_count,
    c.phone_count,
    c.customer_segment,
    c.membership_type,
    c.membership_status,
    c.membership_start_date,
    c.membership_end_date,
    c.donation_total_ytd,
    c.preferred_contact_method,
    c.opt_in_email,
    COALESCE(ts.ticket_purchase_count, 0) AS ticket_purchase_count,
    COALESCE(ts.total_ticket_spend, 0) AS total_ticket_spend,
    COALESCE(ts.tickets_bought, 0) AS tickets_bought,
    COALESCE(ts.last_ticket_date, '1900-01-01'::DATE) AS last_ticket_date,
    COALESCE(rl.retail_purchase_count, 0) AS retail_purchase_count,
    COALESCE(rl.total_retail_spend, 0) AS total_retail_spend,
    COALESCE(rl.retail_items_bought, 0) AS retail_items_bought,
    COALESCE(rl.last_retail_date, '1900-01-01'::DATE) AS last_retail_date,
    COALESCE(ts.total_ticket_spend, 0) + COALESCE(rl.total_retail_spend, 0) AS total_pos_spend,
    COALESCE(ts.total_ticket_spend, 0) + COALESCE(rl.total_retail_spend, 0) + COALESCE(c.donation_total_ytd, 0) AS total_lifetime_value,
    GREATEST(
        COALESCE(ts.last_ticket_date, '1900-01-01'::DATE),
        COALESCE(rl.last_retail_date, '1900-01-01'::DATE)
    ) AS last_transaction_date,
    CASE
        WHEN COALESCE(ts.total_ticket_spend, 0) + COALESCE(rl.total_retail_spend, 0) + COALESCE(c.donation_total_ytd, 0) >= 1000 THEN 'High Value'
        WHEN COALESCE(ts.total_ticket_spend, 0) + COALESCE(rl.total_retail_spend, 0) + COALESCE(c.donation_total_ytd, 0) >= 200 THEN 'Medium Value'
        WHEN COALESCE(ts.total_ticket_spend, 0) + COALESCE(rl.total_retail_spend, 0) + COALESCE(c.donation_total_ytd, 0) > 0 THEN 'Low Value'
        ELSE 'No Spend'
    END AS ltv_tier
FROM MUSEUM_DW_PROD.GOLD.dim_customer c
LEFT JOIN (
    SELECT
        customer_id,
        COUNT(DISTINCT transaction_id) AS ticket_purchase_count,
        SUM(total_amount) AS total_ticket_spend,
        COUNT(*) AS tickets_bought,
        MAX(transaction_date)::DATE AS last_ticket_date
    FROM MUSEUM_DW_PROD.GOLD.fct_ticket_sales
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
) ts ON c.customer_id = ts.customer_id
LEFT JOIN (
    SELECT
        customer_id,
        COUNT(DISTINCT transaction_id) AS retail_purchase_count,
        SUM(total_amount) AS total_retail_spend,
        SUM(quantity) AS retail_items_bought,
        MAX(transaction_date)::DATE AS last_retail_date
    FROM MUSEUM_DW_PROD.GOLD.fct_retail_line_items
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
) rl ON c.customer_id = rl.customer_id
        );
      
  