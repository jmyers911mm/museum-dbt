SELECT
    contact_id,
    full_name,
    email,
    phone,
    membership_type,
    computed_membership_status AS membership_status,
    membership_start_date,
    membership_end_date,
    membership_duration_days,
    donor_tier,
    donation_total_ytd,
    preferred_contact_method,
    opt_in_email,
    days_since_last_visit,
    created_date AS member_since,
    last_modified_date AS last_updated,
    _loaded_at
FROM {{ ref('silver_sf_crm') }}
