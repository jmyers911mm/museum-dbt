
  
    

        create or replace transient table MUSEUM_DW_PROD.ML_FEATURES.ml_visitor_forecast_training
         as
        (

SELECT
    visit_date::TIMESTAMP_NTZ AS ds,
    total_visitors AS y,
    day_of_week,
    CASE WHEN EXTRACT(DOW FROM visit_date) IN (0, 6) THEN 1 ELSE 0 END AS is_weekend,
    EXTRACT(MONTH FROM visit_date) AS month_num,
    ticket_revenue + retail_revenue AS total_revenue,
    ticket_transactions,
    gates_active
FROM MUSEUM_DW_PROD.GOLD.fct_daily_operations
WHERE total_visitors > 0
ORDER BY visit_date
        );
      
  