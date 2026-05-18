{% test hashdiff_integrity(model, hashdiff_column='hashdiff', unique_key='id') %}

WITH collision_check AS (
    SELECT
        {{ hashdiff_column }} AS check_value,
        'COLLISION' AS issue_type
    FROM {{ model }}
    WHERE {{ hashdiff_column }} IS NOT NULL
    GROUP BY {{ hashdiff_column }}
    HAVING COUNT(DISTINCT {{ unique_key }}) > 1
),
null_check AS (
    SELECT
        {{ unique_key }}::VARCHAR AS check_value,
        'NULL_HASH' AS issue_type
    FROM {{ model }}
    WHERE {{ hashdiff_column }} IS NULL
)
SELECT * FROM collision_check
UNION ALL
SELECT * FROM null_check

{% endtest %}
