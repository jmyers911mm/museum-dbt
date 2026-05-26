SELECT
    capacity_date,
    entry_window_start,
    entry_window_end,
    ticket_type,
    capacity,
    is_override,
    override_reason,
    _loaded_at
FROM {{ source('bronze', 'raw_ticket_capacity') }}
