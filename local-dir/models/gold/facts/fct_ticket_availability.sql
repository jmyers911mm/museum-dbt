{{
    config(
        materialized='incremental',
        unique_key='availability_key',
        incremental_strategy='merge',
        schema='GOLD',
        cluster_by=['entry_date', 'ticket_type'],
        tags=['intraday', 'critical']
    )
}}

WITH inventory AS (
    SELECT * FROM {{ ref('silver_ticket_inventory') }}
    {% if is_incremental() %}
    WHERE entry_date >= (SELECT MAX(entry_date) - 7 FROM {{ this }})
    {% endif %}
),

date_attrs AS (
    SELECT
        date_day,
        day_name,
        day_of_week_num,
        is_weekend,
        month_name,
        fiscal_year
    FROM {{ ref('dim_date') }}
)

SELECT
    i.inventory_key AS availability_key,
    i.entry_date,
    d.day_name,
    d.day_of_week_num,
    d.is_weekend,
    d.month_name,
    d.fiscal_year,
    i.entry_window_start,
    i.entry_window_end,
    i.ticket_type,
    i.ticket_capacity,
    i.tickets_reserved,
    i.tickets_available,
    i.utilization_pct,
    i.demand_level,
    i.is_override,
    CURRENT_TIMESTAMP() AS _loaded_at
FROM inventory i
LEFT JOIN date_attrs d ON i.entry_date = d.date_day
