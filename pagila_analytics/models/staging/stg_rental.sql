with source as (

    select * from {{ source('pagila', 'rental') }}

),

renamed as (

    select
        rental_id,
        rental_date,
        inventory_id,
        customer_id,
        return_date,
        staff_id,
        last_update,
        _airbyte_extracted_at as source_loaded_at

    from source

)

select * from renamed
