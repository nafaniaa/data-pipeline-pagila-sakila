with films as (

    select
        film_id,
        category_name

    from {{ ref('dim_film') }}
    where category_name is not null

),

aggregated as (

    select
        category_name,
        count(film_id) as film_count

    from films
    group by category_name

),

final as (

    select
        category_name,
        film_count,
        round(
            film_count * 100.0 / sum(film_count) over (),
            2
        ) as film_percentage

    from aggregated

)

select * from final
order by film_count desc
