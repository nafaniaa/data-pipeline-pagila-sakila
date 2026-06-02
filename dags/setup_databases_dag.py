from airflow.decorators import dag
from airflow.providers.postgres.operators.postgres import PostgresOperator
from datetime import datetime

default_args = {
    'owner': 'airflow',
    'start_date': datetime(2023, 1, 1),
}

@dag(
    dag_id='setup_pagila_sakila_databases_decorated',
    default_args=default_args,
    schedule_interval='@once', 
    catchup=False,
    tags=['setup', 'database'],
    template_searchpath=['/opt/airflow/scripts'] 
)
def setup_databases_pipeline():
    
   
    create_pagila_schema = PostgresOperator(
        task_id='create_pagila_schema',
        postgres_conn_id='pagila_conn',
        sql='pagila-schema.sql' 
    )

    populate_pagila_data = PostgresOperator(
        task_id='populate_pagila_data',
        postgres_conn_id='pagila_conn',
        sql='pagila-data.sql'
    )

    create_sakila_schema = PostgresOperator(
        task_id='create_sakila_schema',
        postgres_conn_id='sakila_conn',
        sql='sakila-schema.sql'
    )

    populate_sakila_data = PostgresOperator(
        task_id='populate_sakila_data',
        postgres_conn_id='sakila_conn',
        sql='sakila-data.sql'
    )

    create_pagila_schema >> populate_pagila_data
    create_sakila_schema >> populate_sakila_data

setup_databases_pipeline()