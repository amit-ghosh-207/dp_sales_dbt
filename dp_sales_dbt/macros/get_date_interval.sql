
{%- macro get_date_interval(business_date_column, start_date=none, interval_days=none) -%}


    {%- if start_date is none -%}
        {%- set param_start_date = var("param_start_date", env_var("param_start_date", "none")) -%}
        {%- if param_start_date == "none" -%}
            {%- set start_date = modules.datetime.date.today().strftime('%Y-%m-%d') -%}
        {%- else -%}
            {%- set start_date = param_start_date -%}
        {%- endif -%}
    {%- endif -%}

    {%- if interval_days is none -%}
        {%- set param_interval_days = var("param_interval_days", env_var("param_interval_days", "none")) -%}
        {%- if param_interval_days == "none" -%}
            {%- set interval_days = 1 -%}
        {%- else -%}
            {%- set interval_days = param_interval_days -%}
        {%- endif -%}
    {%- endif -%}

    {{ business_date_column }} BETWEEN '{{ start_date }}'::DATE - INTERVAL {{ interval_days }} DAY AND '{{ start_date }}'::DATE

{%- endmacro -%}
