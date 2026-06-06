with actors as (

    select * from {{ ref('stg_actor') }}

),

film_counts as (

    select
        actor_id,
        count(distinct film_id) as film_count

    from {{ ref('int_film_actor_bridge') }}
    group by actor_id

),

final as (

    select
        actors.actor_id,
        actors.first_name,
        actors.last_name,
        actors.first_name || ' ' || actors.last_name as full_name,
        coalesce(film_counts.film_count, 0) as film_count,
        actors.last_update

    from actors
    left join film_counts
        on actors.actor_id = film_counts.actor_id

)

select * from final
