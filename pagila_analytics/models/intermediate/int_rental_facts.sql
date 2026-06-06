with rentals as (

    select * from {{ ref('stg_rental') }}

),

inventory as (

    select * from {{ ref('stg_inventory') }}

),

payments as (

    select
        payment_id,
        rental_id,
        amount,
        payment_date

    from {{ ref('stg_payment') }}
    qualify row_number() over (
        partition by rental_id
        order by payment_date desc, payment_id desc
    ) = 1

),

joined as (

    select
        rentals.rental_id,
        rentals.rental_date,
        rentals.return_date,
        rentals.customer_id,
        rentals.staff_id,
        rentals.inventory_id,
        inventory.film_id,
        inventory.store_id,
        payments.payment_id,
        payments.amount as payment_amount,
        payments.payment_date,
        case
            when rentals.return_date is not null
                then datediff('hour', rentals.rental_date, rentals.return_date)
            else null
        end as rental_duration_hours,
        rentals.return_date is not null as is_returned

    from rentals
    inner join inventory
        on rentals.inventory_id = inventory.inventory_id
    inner join payments
        on rentals.rental_id = payments.rental_id

)

select * from joined
