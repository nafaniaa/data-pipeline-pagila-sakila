with source as (

    select * from {{ source('pagila', 'inventory') }}

),

renamed as (

    select
        inventory_id,
        film_id,
        store_id,
        last_update,
        _airbyte_extracted_at as source_loaded_at

    from source

)

select * from renamed
