
  
    

        create or replace transient table MUSEUM_DW_PROD.ML_FEATURES.ml_member_churn_features
         as
        (SELECT
    m.contact_id,
    m.membership_type,
    m.computed_membership_status,
    m.donor_tier,
    m.donation_total_ytd,
    m.days_since_last_visit,
    m.ticket_purchase_count,
    m.total_ticket_spend,
    m.retail_purchase_count,
    m.total_retail_spend,
    m.total_pos_spend,
    m.total_lifetime_value,
    m.email_opens,
    m.email_clicks,
    CASE WHEN m.email_opens > 0 THEN m.email_clicks::FLOAT / m.email_opens ELSE 0 END AS email_click_through_rate,
    m.engagement_segment,
    DATEDIFF('day', m.last_interaction_date, CURRENT_DATE()) AS days_since_last_interaction,
    CASE
        WHEN m.computed_membership_status IN ('Expired', 'Lapsed') THEN 1
        WHEN m.computed_membership_status = 'Grace Period' THEN 1
        ELSE 0
    END AS is_churned,
    CASE
        WHEN m.days_since_last_visit > 60
             AND m.computed_membership_status = 'Active'
        THEN 1
        ELSE 0
    END AS churn_risk_flag,
    CURRENT_TIMESTAMP() AS _feature_computed_at
FROM MUSEUM_DW_PROD.GOLD.fct_member_360 m
        );
      
  