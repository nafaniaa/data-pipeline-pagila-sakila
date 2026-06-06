with films as (

    select * from {{ ref('stg_film') }}

),

film_category as (

    select
        film_id,
        category_id

    from {{ source('pagila', 'film_category') }}
    qualify row_number() over (
        partition by film_id
        order by category_id
    ) = 1

),

categories as (

    select * from {{ ref('stg_category') }}

),

final as (

    select
        films.film_id,
        films.title,
        films.description,
        films.release_year,
        films.language_id,
        films.rental_duration,
        films.rental_rate,
        films.film_length_minutes,
        films.replacement_cost,
        films.rating,
        categories.category_id,
        categories.category_name,
        films.last_update

    from films
    left join film_category
        on films.film_id = film_category.film_id
    left join categories
        on film_category.category_id = categories.category_id

)

select * from final
