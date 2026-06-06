with source as (

    select * from {{ source('pagila', 'customer') }}

),

renamed as (

    select
        customer_id,
        store_id,
        trim(first_name) as first_name,
        trim(last_name) as last_name,
        lower(trim(email)) as email,
        address_id,
        activebool as is_active,
        create_date,
        last_update,
        _airbyte_extracted_at as source_loaded_at

    from source

)

select * from renamed
