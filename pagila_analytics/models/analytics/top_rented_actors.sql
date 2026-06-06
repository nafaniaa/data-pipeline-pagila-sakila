with rentals as (

    select
        film_id,
        rental_id

    from {{ ref('fact_rental') }}

),

film_actors as (

    select
        film_id,
        actor_id,
        actor_first_name,
        actor_last_name

    from {{ ref('int_film_actor_bridge') }}

),

joined as (

    select
        film_actors.actor_id,
        film_actors.actor_first_name,
        film_actors.actor_last_name,
        rentals.rental_id

    from rentals
    inner join film_actors
        on rentals.film_id = film_actors.film_id

),

final as (

    select
        actor_id,
        actor_first_name,
        actor_last_name,
        actor_first_name || ' ' || actor_last_name as actor_full_name,
        count(distinct rental_id) as rental_count

    from joined
    group by
        actor_id,
        actor_first_name,
        actor_last_name

)

select * from final
order by rental_count desc
