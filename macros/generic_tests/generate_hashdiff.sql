{% macro generate_hashdiff(columns) %}
    MD5(CONCAT_WS('||',
        {% for column in columns %}
        COALESCE(CAST({{ column }} AS VARCHAR), '^^NULL^^'){{ ',' if not loop.last }}
        {% endfor %}
    ))
{% endmacro %}
