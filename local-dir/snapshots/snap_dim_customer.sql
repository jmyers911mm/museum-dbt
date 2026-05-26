{% snapshot snap_dim_customer %}

{{
    config(
        target_schema='SILVER',
        unique_key='customer_id',
        strategy='check',
        check_cols=['customer_segment', 'membership_type', 'membership_status', 'primary_email', 'primary_phone', 'email_count', 'phone_count']
    )
}}

SELECT
    customer_id,
    crm_contact_id,
    full_name,
    primary_email,
    primary_phone,
    email_count,
    phone_count,
    membership_type,
    membership_status,
    customer_segment
FROM {{ ref('dim_customer') }}

{% endsnapshot %}
