with source as (

    select * from {{ source('pagila', 'address') }}

),

renamed as (

    select
        address_id,
        trim(address) as address_line1,
        trim(address2) as address_line2,
        trim(district) as district,
        city_id,
        trim(postal_code) as postal_code,
        trim(phone) as phone,
        last_update,
        _airbyte_extracted_at as source_loaded_at

    from source

)

select * from renamed
