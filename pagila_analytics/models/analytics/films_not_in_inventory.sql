with films as (

    select
        film_id,
        title,
        category_name,
        rental_rate

    from {{ ref('dim_film') }}

),

inventory_films as (

    select distinct film_id
    from {{ ref('stg_inventory') }}

),

final as (

    select
        films.film_id,
        films.title,
        films.category_name,
        films.rental_rate

    from films
    left join inventory_films
        on films.film_id = inventory_films.film_id
    where inventory_films.film_id is null

)

select * from final
order by title
