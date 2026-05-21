
  
    

        create or replace transient table MUSEUM_DW_PROD.SILVER.silver_ticket_inventory
        copy grants as
        (select * from (
              

WITH capacity AS (
    SELECT
        capacity_date AS entry_date,
        entry_window_start,
        entry_window_end,
        ticket_type,
        capacity,
        is_override
    FROM MUSEUM_DW_PROD.SILVER.stg_ticket_capacity
),

reservations AS (
    SELECT
        entry_date,
        entry_window_start,
        mapped_ticket_type AS ticket_type,
        SUM(quantity) AS tickets_reserved
    FROM MUSEUM_DW_PROD.SILVER.stg_pos_tickets
    WHERE entry_time_purchased IS NOT NULL
    GROUP BY 1, 2, 3
)

SELECT
    c.entry_date || '-' || c.entry_window_start || '-' || c.ticket_type AS inventory_key,
    c.entry_date,
    c.entry_window_start,
    c.entry_window_end,
    c.ticket_type,
    c.capacity AS ticket_capacity,
    COALESCE(r.tickets_reserved, 0) AS tickets_reserved,
    c.capacity - COALESCE(r.tickets_reserved, 0) AS tickets_available,
    ROUND(COALESCE(r.tickets_reserved, 0)::FLOAT / NULLIF(c.capacity, 0) * 100, 2) AS utilization_pct,
    CASE
        WHEN COALESCE(r.tickets_reserved, 0)::FLOAT / NULLIF(c.capacity, 0) >= 0.95 THEN 'Sold Out'
        WHEN COALESCE(r.tickets_reserved, 0)::FLOAT / NULLIF(c.capacity, 0) >= 0.80 THEN 'High Demand'
        WHEN COALESCE(r.tickets_reserved, 0)::FLOAT / NULLIF(c.capacity, 0) >= 0.50 THEN 'Moderate'
        WHEN COALESCE(r.tickets_reserved, 0)::FLOAT / NULLIF(c.capacity, 0) >= 0.20 THEN 'Low'
        ELSE 'Very Low'
    END AS demand_level,
    c.is_override,
    CURRENT_TIMESTAMP() AS _loaded_at
FROM capacity c
LEFT JOIN reservations r
    ON c.entry_date = r.entry_date
    AND c.entry_window_start = r.entry_window_start
    AND c.ticket_type = r.ticket_type


              ) order by (entry_date, ticket_type)
        );
      alter  table MUSEUM_DW_PROD.SILVER.silver_ticket_inventory cluster by (entry_date, ticket_type);
  