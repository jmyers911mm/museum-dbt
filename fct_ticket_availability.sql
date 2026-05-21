
  
    

        create or replace transient table MUSEUM_DW_PROD.GOLD.fct_ticket_availability
        copy grants as
        (select * from (
              

WITH inventory AS (
    SELECT * FROM MUSEUM_DW_PROD.SILVER.silver_ticket_inventory
    
),

date_attrs AS (
    SELECT
        date_day,
        day_name,
        day_of_week_num,
        is_weekend,
        month_name,
        fiscal_year
    FROM MUSEUM_DW_PROD.GOLD.dim_date
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
              ) order by (entry_date, ticket_type)
        );
      alter  table MUSEUM_DW_PROD.GOLD.fct_ticket_availability cluster by (entry_date, ticket_type);
  