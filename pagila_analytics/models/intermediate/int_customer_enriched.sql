with customers as (

    select * from {{ ref('stg_customer') }}

),

addresses as (

    select * from {{ ref('stg_address') }}

),

cities as (

    select * from {{ ref('stg_city') }}

),

countries as (

    select
        country_id,
        trim(country) as country_name,
        last_update

    from {{ source('pagila', 'country') }}

),

enriched as (

    select
        customers.customer_id,
        customers.store_id,
        customers.first_name,
        customers.last_name,
        customers.first_name || ' ' || customers.last_name as full_name,
        customers.email,
        customers.is_active,
        customers.create_date,
        addresses.address_id,
        addresses.address_line1,
        addresses.address_line2,
        addresses.district,
        addresses.postal_code,
        addresses.phone,
        cities.city_id,
        cities.city_name,
        countries.country_id,
        countries.country_name,
        customers.last_update

    from customers
    inner join addresses
        on customers.address_id = addresses.address_id
    inner join cities
        on addresses.city_id = cities.city_id
    inner join countries
        on cities.country_id = countries.country_id

)

select * from enriched
