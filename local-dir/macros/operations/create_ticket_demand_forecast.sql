{% macro create_ticket_demand_forecast() %}
    {#
        Creates a Snowflake ML FORECAST model for ticket demand prediction.
        Forecasts daily ticket reservations per ticket type for the next 90 days.

        Usage:
            dbt run-operation create_ticket_demand_forecast

        Prerequisites:
            - ml_ticket_demand_features must be populated
            - Requires warehouse with ML capabilities

        The forecast uses multi-series mode (one series per ticket_type).
    #}

    {% if execute %}

        {% set create_model %}
            CREATE OR REPLACE SNOWFLAKE.ML.FORECAST MUSEUM_DW_DEV.ML_FEATURES.FORECAST_TICKET_DEMAND(
                INPUT_DATA => SYSTEM$QUERY_REFERENCE(
                    'SELECT
                        entry_date::TIMESTAMP_NTZ AS ds,
                        ticket_type AS series,
                        daily_reserved AS y
                    FROM MUSEUM_DW_DEV.ML_FEATURES.ML_TICKET_DEMAND_FEATURES
                    WHERE entry_date IS NOT NULL
                    ORDER BY ticket_type, entry_date'
                ),
                SERIES_COLNAME => 'SERIES',
                TIMESTAMP_COLNAME => 'DS',
                TARGET_COLNAME => 'Y'
            )
        {% endset %}

        {% do run_query(create_model) %}
        {{ log("FORECAST: Model FORECAST_TICKET_DEMAND created successfully.", info=True) }}
        {{ log("FORECAST: Run forecasts with:", info=True) }}
        {{ log("  CALL MUSEUM_DW_DEV.ML_FEATURES.FORECAST_TICKET_DEMAND!FORECAST(FORECASTING_PERIODS => 90);", info=True) }}

    {% endif %}

{% endmacro %}
