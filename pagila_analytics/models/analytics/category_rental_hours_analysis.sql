with rentals as (

    select
        film_id,
        rental_duration_hours

    from {{ ref('fact_rental') }}
    where rental_duration_hours is not null

),

films as (

    select
        film_id,
        category_name

    from {{ ref('dim_film') }}
    where category_name is not null

),

joined as (

    select
        films.category_name,
        rentals.rental_duration_hours

    from rentals
    inner join films
        on rentals.film_id = films.film_id

),

final as (

    select
        category_name,
        count(*) as rental_count,
        sum(rental_duration_hours) as total_rental_hours,
        round(avg(rental_duration_hours), 2) as avg_rental_hours

    from joined
    group by category_name

)

select * from final
order by total_rental_hours desc
