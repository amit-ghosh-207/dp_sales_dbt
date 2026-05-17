{{ config(materialized='view') }}

select 
*,
get_current_timestamp() as load_ts
from {{ source('external_source', 'customer') }}
