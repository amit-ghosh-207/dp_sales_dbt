
{% macro get_date_interval(business_date_column, start_date, interval_days) %} 

{{ business_date_column }} BETWEEN {{ start_date }}::DATE AND {{ start_date }}::DATE + INTERVAL {{ interval_days }} DAY  

{% endmacro %}