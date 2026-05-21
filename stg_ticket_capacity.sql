
  create or replace   view MUSEUM_DW_PROD.SILVER.stg_ticket_capacity
  
    
    
(
  
    "CAPACITY_DATE" COMMENT $$$$, 
  
    "ENTRY_WINDOW_START" COMMENT $$$$, 
  
    "ENTRY_WINDOW_END" COMMENT $$$$, 
  
    "TICKET_TYPE" COMMENT $$$$, 
  
    "CAPACITY" COMMENT $$$$, 
  
    "IS_OVERRIDE" COMMENT $$$$, 
  
    "OVERRIDE_REASON" COMMENT $$$$, 
  
    "_LOADED_AT" COMMENT $$$$
  
)

   as (
    SELECT
    capacity_date,
    entry_window_start,
    entry_window_end,
    ticket_type,
    capacity,
    is_override,
    override_reason,
    _loaded_at
FROM MUSEUM_DW_PROD.BRONZE.raw_ticket_capacity
  );

