
  
    

        create or replace transient table MUSEUM_DW_PROD.GOLD.dim_date
          
  (
    date_day DATE,
    year_num NUMBER,
    quarter_num NUMBER,
    month_num NUMBER,
    month_name VARCHAR,
    week_of_year NUMBER,
    day_of_week_num NUMBER,
    day_name VARCHAR,
    day_of_month NUMBER,
    day_of_year NUMBER,
    is_weekend BOOLEAN,
    fiscal_year VARCHAR,
    fiscal_quarter NUMBER,
    is_today BOOLEAN,
    days_ago NUMBER
    
    )

          
        
        copy grants as
        (
    select date_day, year_num, quarter_num, month_num, month_name, week_of_year, day_of_week_num, day_name, day_of_month, day_of_year, is_weekend, fiscal_year, fiscal_quarter, is_today, days_ago
    from (
        

WITH date_spine AS (
    SELECT
        DATEADD('day', seq4(), '2025-01-01'::DATE) AS date_day
    FROM TABLE(GENERATOR(ROWCOUNT => 1096))
)
SELECT
    date_day,
    YEAR(date_day) AS year_num,
    QUARTER(date_day) AS quarter_num,
    MONTH(date_day) AS month_num,
    MONTHNAME(date_day) AS month_name,
    WEEKOFYEAR(date_day) AS week_of_year,
    DAYOFWEEKISO(date_day) AS day_of_week_num,
    DAYNAME(date_day) AS day_name,
    DAY(date_day) AS day_of_month,
    DAYOFYEAR(date_day) AS day_of_year,
    CASE WHEN DAYOFWEEKISO(date_day) IN (6, 7) THEN TRUE ELSE FALSE END AS is_weekend,
    CASE
        WHEN MONTH(date_day) >= 7 THEN 'FY' || (YEAR(date_day) + 1)::VARCHAR
        ELSE 'FY' || YEAR(date_day)::VARCHAR
    END AS fiscal_year,
    CASE
        WHEN MONTH(date_day) IN (7, 8, 9) THEN 1
        WHEN MONTH(date_day) IN (10, 11, 12) THEN 2
        WHEN MONTH(date_day) IN (1, 2, 3) THEN 3
        ELSE 4
    END AS fiscal_quarter,
    CASE WHEN date_day = CURRENT_DATE() THEN TRUE ELSE FALSE END AS is_today,
    DATEDIFF('day', date_day, CURRENT_DATE()) AS days_ago
FROM date_spine
    ) as model_subq
        );
      
  