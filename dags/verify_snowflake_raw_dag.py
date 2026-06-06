from datetime import datetime

from airflow.decorators import dag
from airflow.providers.snowflake.operators.snowflake import SnowflakeOperator

default_args = {
    "owner": "airflow",
    "start_date": datetime(2023, 1, 1),
}

SNOWFLAKE_CONN_ID = "snowflake_dev_conn"


@dag(
    dag_id="verify_snowflake_raw_data",
    default_args=default_args,
    schedule_interval=None,
    catchup=False,
    tags=["snowflake", "validation", "development_role"],
    doc_md="""
    Validates raw replication in Snowflake using the service connection.

    Credentials are read from Airflow Connection `snowflake_dev_conn`
    (AIRFLOW_DEV_USER + DEVELOPMENT_ROLE). No admin credentials in code.
    """,
)
def verify_snowflake_raw_data():
    count_pagila_films = SnowflakeOperator(
        task_id="count_pagila_films",
        snowflake_conn_id=SNOWFLAKE_CONN_ID,
        sql="SELECT COUNT(*) AS film_count FROM RAW_DB.PAGILA.FILM;",
    )

    count_sakila_films = SnowflakeOperator(
        task_id="count_sakila_films",
        snowflake_conn_id=SNOWFLAKE_CONN_ID,
        sql="SELECT COUNT(*) AS film_count FROM RAW_DB.SAKILA.FILM;",
    )

    [count_pagila_films, count_sakila_films]


verify_snowflake_raw_data()
