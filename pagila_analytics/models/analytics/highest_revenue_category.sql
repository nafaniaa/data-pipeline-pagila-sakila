with revenue as (

    select
        film_id,
        payment_amount

    from {{ ref('fact_revenue') }}

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
        revenue.payment_amount

    from revenue
    inner join films
        on revenue.film_id = films.film_id

),

final as (

    select
        category_name,
        sum(payment_amount) as total_revenue,
        count(*) as payment_count

    from joined
    group by category_name

)

select * from final
order by total_revenue desc
