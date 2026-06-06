with source as (

    select * from {{ source('pagila', 'city') }}

),

renamed as (

    select
        city_id,
        trim(city) as city_name,
        country_id,
        last_update,
        _airbyte_extracted_at as source_loaded_at

    from source

)

select * from renamed
