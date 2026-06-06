with source as (

    select * from {{ source('pagila', 'film') }}

),

renamed as (

    select
        film_id,
        title,
        description,
        release_year,
        language_id,
        original_language_id,
        rental_duration,
        cast(rental_rate as numeric(4, 2)) as rental_rate,
        length as film_length_minutes,
        cast(replacement_cost as numeric(5, 2)) as replacement_cost,
        rating,
        last_update,
        _airbyte_extracted_at as source_loaded_at

    from source

)

select * from renamed
