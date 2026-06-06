with source as (

    select * from {{ source('pagila', 'payment') }}

),

renamed as (

    select
        payment_id,
        customer_id,
        staff_id,
        rental_id,
        cast(amount as numeric(5, 2)) as amount,
        payment_date,
        _airbyte_extracted_at as source_loaded_at

    from source

)

select * from renamed
