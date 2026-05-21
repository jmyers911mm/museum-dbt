
  
    

        create or replace transient table MUSEUM_DW_PROD.GOLD.rpt_customer_ltv
        copy grants as
        (SELECT
    c.customer_id,
    c.full_name,
    c.primary_email,
    c.primary_phone,
    c.customer_segment,
    c.membership_type,
    c.membership_status,
    c.donation_total_ytd,
    COALESCE(ts.total_ticket_spend, 0) AS total_ticket_spend,
    COALESCE(rl.total_retail_spend, 0) AS total_retail_spend,
    COALESCE(ts.total_ticket_spend, 0) + COALESCE(rl.total_retail_spend, 0) AS total_pos_spend,
    COALESCE(ts.total_ticket_spend, 0) + COALESCE(rl.total_retail_spend, 0) + COALESCE(c.donation_total_ytd, 0) AS total_lifetime_value,
    COALESCE(ts.ticket_visits, 0) AS ticket_visits,
    COALESCE(rl.retail_visits, 0) AS retail_visits,
    COALESCE(ts.ticket_visits, 0) + COALESCE(rl.retail_visits, 0) AS total_visits,
    COALESCE(ts.first_ticket_date, rl.first_retail_date) AS first_transaction_date,
    GREATEST(COALESCE(ts.last_ticket_date, '1900-01-01'), COALESCE(rl.last_retail_date, '1900-01-01')) AS last_transaction_date,
    DATEDIFF('day',
        COALESCE(ts.first_ticket_date, rl.first_retail_date),
        GREATEST(COALESCE(ts.last_ticket_date, '1900-01-01'), COALESCE(rl.last_retail_date, '1900-01-01'))
    ) AS customer_tenure_days,
    CASE
        WHEN COALESCE(ts.total_ticket_spend, 0) + COALESCE(rl.total_retail_spend, 0) + COALESCE(c.donation_total_ytd, 0) >= 1000 THEN 'Platinum'
        WHEN COALESCE(ts.total_ticket_spend, 0) + COALESCE(rl.total_retail_spend, 0) + COALESCE(c.donation_total_ytd, 0) >= 500 THEN 'Gold'
        WHEN COALESCE(ts.total_ticket_spend, 0) + COALESCE(rl.total_retail_spend, 0) + COALESCE(c.donation_total_ytd, 0) >= 100 THEN 'Silver'
        ELSE 'Bronze'
    END AS ltv_tier,
    COALESCE(ts.avg_ticket_spend, 0) AS avg_ticket_spend_per_visit,
    COALESCE(rl.avg_retail_spend, 0) AS avg_retail_spend_per_visit
FROM MUSEUM_DW_PROD.GOLD.dim_customer c
LEFT JOIN (
    SELECT
        customer_id,
        SUM(total_amount) AS total_ticket_spend,
        COUNT(DISTINCT transaction_id) AS ticket_visits,
        MIN(transaction_date)::DATE AS first_ticket_date,
        MAX(transaction_date)::DATE AS last_ticket_date,
        DIV0(SUM(total_amount), COUNT(DISTINCT transaction_id)) AS avg_ticket_spend
    FROM MUSEUM_DW_PROD.GOLD.fct_ticket_sales
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
) ts ON c.customer_id = ts.customer_id
LEFT JOIN (
    SELECT
        customer_id,
        SUM(total_amount) AS total_retail_spend,
        COUNT(DISTINCT transaction_id) AS retail_visits,
        MIN(transaction_date)::DATE AS first_retail_date,
        MAX(transaction_date)::DATE AS last_retail_date,
        DIV0(SUM(total_amount), COUNT(DISTINCT transaction_id)) AS avg_retail_spend
    FROM MUSEUM_DW_PROD.GOLD.fct_retail_line_items
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
) rl ON c.customer_id = rl.customer_id
WHERE COALESCE(ts.total_ticket_spend, 0) + COALESCE(rl.total_retail_spend, 0) + COALESCE(c.donation_total_ytd, 0) > 0
        );
      
  