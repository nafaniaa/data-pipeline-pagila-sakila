with rental_bounds as (

    select
        min(cast(rental_date as date)) as min_date,
        max(greatest(
            cast(rental_date as date),
            cast(payment_date as date)
        )) as max_date

    from {{ ref('int_rental_facts') }}

),

date_spine as (

    select
        dateadd(day, seq4(), rental_bounds.min_date) as date_day

    from rental_bounds,
        table(generator(rowcount => 2000))

    where dateadd(day, seq4(), rental_bounds.min_date) <= rental_bounds.max_date

),

final as (

    select
        date_day,
        to_number(to_char(date_day, 'YYYYMMDD')) as date_key,
        year(date_day) as year,
        quarter(date_day) as quarter,
        month(date_day) as month,
        monthname(date_day) as month_name,
        day(date_day) as day_of_month,
        dayofweek(date_day) as day_of_week,
        dayname(date_day) as day_name,
        case
            when dayofweek(date_day) in (0, 6) then true
            else false
        end as is_weekend

    from date_spine

)

select * from final
