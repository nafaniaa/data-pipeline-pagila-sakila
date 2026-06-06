with film_actor as (

    select
        actor_id,
        film_id,
        last_update

    from {{ source('pagila', 'film_actor') }}

),

films as (

    select * from {{ ref('stg_film') }}

),

actors as (

    select * from {{ ref('stg_actor') }}

),

joined as (

    select
        film_actor.actor_id,
        film_actor.film_id,
        actors.first_name as actor_first_name,
        actors.last_name as actor_last_name,
        films.title as film_title,
        films.rating as film_rating,
        film_actor.last_update,
        film_actor.actor_id || '-' || film_actor.film_id as film_actor_key

    from film_actor
    inner join films
        on film_actor.film_id = films.film_id
    inner join actors
        on film_actor.actor_id = actors.actor_id

)

select * from joined
