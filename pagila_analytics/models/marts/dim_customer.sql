select
    customer_id,
    store_id,
    first_name,
    last_name,
    full_name,
    email,
    is_active,
    create_date,
    address_id,
    address_line1,
    address_line2,
    district,
    postal_code,
    phone,
    city_id,
    city_name,
    country_id,
    country_name,
    last_update

from {{ ref('int_customer_enriched') }}
