with source as (

    select * from {{ source('pagila', 'category') }}

),

renamed as (

    select
        category_id,
        trim(name) as category_name,
        last_update,
        _airbyte_extracted_at as source_loaded_at

    from source

)

select * from renamed
