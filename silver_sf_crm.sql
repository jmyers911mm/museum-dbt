
  
    

        create or replace transient table MUSEUM_DW_PROD.SILVER.silver_sf_crm
        copy grants as
        (SELECT
    contact_id,
    first_name,
    last_name,
    first_name || ' ' || last_name AS full_name,
    email,
    phone,
    membership_type,
    membership_status,
    CASE
        WHEN membership_status = 'Active' AND membership_end_date >= CURRENT_DATE() THEN 'Active'
        WHEN membership_status = 'Active' AND membership_end_date < CURRENT_DATE() THEN 'Grace Period'
        WHEN membership_status = 'Expired' THEN 'Expired'
        WHEN membership_status = 'Lapsed' THEN 'Lapsed'
        ELSE 'Unknown'
    END AS computed_membership_status,
    membership_start_date,
    membership_end_date,
    DATEDIFF('day', membership_start_date, membership_end_date) AS membership_duration_days,
    donation_total_ytd,
    CASE
        WHEN donation_total_ytd >= 5000 THEN 'Major Donor'
        WHEN donation_total_ytd >= 1000 THEN 'Mid-Level Donor'
        WHEN donation_total_ytd >= 100 THEN 'Donor'
        WHEN donation_total_ytd > 0 THEN 'Small Donor'
        ELSE 'Non-Donor'
    END AS donor_tier,
    last_donation_date,
    last_visit_date,
    DATEDIFF('day', last_visit_date, CURRENT_DATE()) AS days_since_last_visit,
    preferred_contact_method,
    opt_in_email,
    created_date,
    last_modified_date,
    hashdiff,
    _loaded_at
FROM MUSEUM_DW_PROD.SILVER.stg_sf_crm
        );
      
  