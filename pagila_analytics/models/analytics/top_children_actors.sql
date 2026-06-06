with children_films as (

    select film_id
    from {{ ref('dim_film') }}
    where lower(category_name) = 'children'

),

children_rentals as (

    select
        rentals.rental_id,
        rentals.film_id

    from {{ ref('fact_rental') }} as rentals
    inner join children_films
        on rentals.film_id = children_films.film_id

),

children_actors as (

    select
        bridge.actor_id,
        bridge.actor_first_name,
        bridge.actor_last_name,
        children_rentals.rental_id

    from children_rentals
    inner join {{ ref('int_film_actor_bridge') }} as bridge
        on children_rentals.film_id = bridge.film_id

),

final as (

    select
        actor_id,
        actor_first_name,
        actor_last_name,
        actor_first_name || ' ' || actor_last_name as actor_full_name,
        count(distinct rental_id) as children_rental_count

    from children_actors
    group by
        actor_id,
        actor_first_name,
        actor_last_name

)

select * from final
order by children_rental_count desc
