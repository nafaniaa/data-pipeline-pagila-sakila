select
    payment_id,
    rental_id,
    customer_id,
    staff_id,
    film_id,
    store_id,
    cast(payment_date as date) as payment_date_key,
    payment_date,
    payment_amount,
    rental_duration_hours,
    is_returned

from {{ ref('int_rental_facts') }}
