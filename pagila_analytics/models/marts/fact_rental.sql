select
    rental_id,
    customer_id,
    staff_id,
    film_id,
    store_id,
    inventory_id,
    cast(rental_date as date) as rental_date_key,
    cast(return_date as date) as return_date_key,
    rental_date,
    return_date,
    rental_duration_hours,
    is_returned,
    payment_id,
    payment_amount,
    payment_date

from {{ ref('int_rental_facts') }}
