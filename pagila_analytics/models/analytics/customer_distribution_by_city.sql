with aggregated as (

    select
        city_name,
        country_name,
        count(customer_id) as customer_count

    from {{ ref('dim_customer') }}
    group by city_name, country_name

),

final as (

    select
        city_name,
        country_name,
        customer_count,
        round(
            customer_count * 100.0 / sum(customer_count) over (),
            2
        ) as customer_percentage

    from aggregated

)

select * from final
order by customer_count desc
