{{
  config(
    unique_key = "raw_customer_hash_key",
    tags = ["core", "events"]
  )
}}

with cte_raw_customer as(
select 
customer_id,
customer_name,
customer_email,
start_date,
end_date,
status,
filename,
get_current_timestamp() as load_ts
from {{ source('external_source', 'customer') }}
)
select 
MD5(
    concat_ws(
        '|', 
        COALESCE(customer_id, ''), 
        COALESCE(customer_name, ''),
        COALESCE(customer_email, ''), 
        COALESCE(start_date, '1990-01-01'),
        COALESCE(end_date, '2999-01-01'),
        COALESCE(status, ''),
        COALESCE(filename, ''),
        COALESCE(load_ts, '')
    )
) as raw_customer_hash_key,
*
from cte_raw_customer
{% if is_incremental() %}
where filename not in raw_customer(
    select filename from {{ this }}
)
{% endif %}
