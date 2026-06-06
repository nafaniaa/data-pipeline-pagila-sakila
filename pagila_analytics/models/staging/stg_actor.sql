with source as (

    select * from {{ source('pagila', 'actor') }}

),

renamed as (

    select
        actor_id,
        trim(first_name) as first_name,
        trim(last_name) as last_name,
        last_update,
        _airbyte_extracted_at as source_loaded_at

    from source

)

select * from renamed
