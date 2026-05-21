{% test z_score_outlier(model, column_name, max_zscore=3) %}
WITH stats AS (
    SELECT
        AVG({{ column_name }}) AS mean_val,
        STDDEV({{ column_name }}) AS stddev_val
    FROM {{ model }}
    WHERE {{ column_name }} IS NOT NULL
)
SELECT {{ column_name }}
FROM {{ model }}, stats
WHERE stats.stddev_val > 0
  AND ABS(({{ column_name }} - stats.mean_val) / stats.stddev_val) > {{ max_zscore }}
{% endtest %}

{% test positive_value(model, column_name) %}
SELECT {{ column_name }}
FROM {{ model }}
WHERE {{ column_name }} < 0
{% endtest %}

{% test value_between(model, column_name, min_value, max_value) %}
SELECT {{ column_name }}
FROM {{ model }}
WHERE {{ column_name }} < {{ min_value }}
   OR {{ column_name }} > {{ max_value }}
{% endtest %}

{% test null_rate_threshold(model, column_name, max_null_pct=50) %}
WITH rates AS (
    SELECT
        COUNT(*) AS total_rows,
        COUNT(CASE WHEN {{ column_name }} IS NULL THEN 1 END) AS null_rows
    FROM {{ model }}
)
SELECT total_rows, null_rows,
       ROUND(null_rows::FLOAT / NULLIF(total_rows, 0) * 100, 2) AS null_pct
FROM rates
WHERE ROUND(null_rows::FLOAT / NULLIF(total_rows, 0) * 100, 2) > {{ max_null_pct }}
{% endtest %}

{% test late_arriving_data(model, timestamp_column, max_lag_hours=72) %}
SELECT {{ timestamp_column }}
FROM {{ model }}
WHERE {{ timestamp_column }} < DATEADD('hour', -{{ max_lag_hours }}, CURRENT_TIMESTAMP())
  AND _loaded_at > DATEADD('hour', -24, CURRENT_TIMESTAMP())
{% endtest %}

{% test daily_volume_bounds(model, date_column, min_rows_per_day=1, max_rows_per_day=10000) %}
WITH daily_counts AS (
    SELECT
        {{ date_column }} AS day_val,
        COUNT(*) AS row_count
    FROM {{ model }}
    GROUP BY 1
)
SELECT day_val, row_count
FROM daily_counts
WHERE row_count < {{ min_rows_per_day }}
   OR row_count > {{ max_rows_per_day }}
{% endtest %}

{% test cardinality_change(model, column_name, min_expected=1, max_expected=100) %}
WITH card AS (
    SELECT COUNT(DISTINCT {{ column_name }}) AS distinct_count
    FROM {{ model }}
)
SELECT distinct_count
FROM card
WHERE distinct_count < {{ min_expected }}
   OR distinct_count > {{ max_expected }}
{% endtest %}

{% test distribution_shift(model, column_name, value, min_pct=0, max_pct=100) %}
WITH counts AS (
    SELECT
        COUNT(*) AS total_rows,
        COUNT(CASE WHEN {{ column_name }} = '{{ value }}' THEN 1 END) AS value_rows
    FROM {{ model }}
)
SELECT total_rows, value_rows,
       ROUND(value_rows::FLOAT / NULLIF(total_rows, 0) * 100, 2) AS actual_pct
FROM counts
WHERE ROUND(value_rows::FLOAT / NULLIF(total_rows, 0) * 100, 2) < {{ min_pct }}
   OR ROUND(value_rows::FLOAT / NULLIF(total_rows, 0) * 100, 2) > {{ max_pct }}
{% endtest %}
