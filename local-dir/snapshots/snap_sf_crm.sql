{% snapshot snap_sf_crm %}

{{
    config(
        target_schema='SILVER',
        unique_key='contact_id',
        strategy='check',
        check_cols=['hashdiff']
    )
}}

SELECT *
FROM {{ ref('stg_sf_crm') }}

{% endsnapshot %}
