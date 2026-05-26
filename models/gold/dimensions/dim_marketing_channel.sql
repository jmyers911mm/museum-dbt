SELECT
    channel_id,
    channel_name,
    display_name,
    is_paid::BOOLEAN AS is_paid,
    cost_model,
    channel_group
FROM {{ ref('ref_marketing_channels') }}
