-- =============================================================================
-- Snowflake setup for Pagila & Sakila ELT pipeline
-- =============================================================================
--
-- HOW TO USE (read before running):
--
--   PART A — BOOTSTRAP (run ONCE on a new Snowflake account)
--     When: first project setup, empty account
--     Who:  ACCOUNTADMIN only
--     Note: uses CREATE OR REPLACE — do NOT re-run if RAW_DB already has data
--
--   PART B — GRANTS REPAIR (safe to re-run anytime)
--     When: Airbyte/Airflow permission errors, after adding new schemas, before dbt
--     Who:  ACCOUNTADMIN only
--     Note: idempotent GRANTs — will not delete existing tables or data
--
--   PART C — VERIFY (read-only checks)
--     When: after Part A or B, or when debugging access issues
--     Who:  any role with visibility (ACCOUNTADMIN recommended)
--
-- =============================================================================


-- =============================================================================
-- PART A — BOOTSTRAP (ONE TIME ONLY)
-- =============================================================================
-- Run this block ONCE when setting up a brand-new environment.
-- Skip entirely if RAW_DB, PAGILA, SAKILA already exist and contain synced data.

USE ROLE ACCOUNTADMIN;

-- Warehouse: smallest size, auto-suspend to control cost
CREATE OR REPLACE WAREHOUSE COMPUTE_WH
    WITH
        WAREHOUSE_SIZE      = 'X-SMALL'
        AUTO_SUSPEND        = 60
        AUTO_RESUME         = TRUE
        INITIALLY_SUSPENDED = TRUE
        COMMENT             = 'ELT compute for pagila/sakila pipeline';

-- Raw landing database
CREATE OR REPLACE DATABASE RAW_DB
    COMMENT = 'Raw layer: Airbyte replication from Postgres sources';

-- One schema per source (per assignment requirements)
CREATE OR REPLACE SCHEMA RAW_DB.PAGILA  COMMENT = 'Raw Pagila tables from Airbyte';
CREATE OR REPLACE SCHEMA RAW_DB.SAKILA  COMMENT = 'Raw Sakila tables from Airbyte';

-- Service role for pipelines (Airbyte, Airflow, dbt) — NOT admin
CREATE OR REPLACE ROLE DEVELOPMENT_ROLE
    COMMENT = 'Non-admin role for ELT pipelines';

-- --- Grants: warehouse & database ---
GRANT USAGE   ON WAREHOUSE COMPUTE_WH TO ROLE DEVELOPMENT_ROLE;
GRANT MONITOR ON WAREHOUSE COMPUTE_WH TO ROLE DEVELOPMENT_ROLE;

GRANT USAGE        ON DATABASE RAW_DB TO ROLE DEVELOPMENT_ROLE;
GRANT CREATE SCHEMA ON DATABASE RAW_DB TO ROLE DEVELOPMENT_ROLE;

-- --- Grants: existing schemas ---
GRANT USAGE, CREATE TABLE, CREATE VIEW, CREATE STAGE, CREATE FILE FORMAT
    ON SCHEMA RAW_DB.PAGILA TO ROLE DEVELOPMENT_ROLE;

GRANT USAGE, CREATE TABLE, CREATE VIEW, CREATE STAGE, CREATE FILE FORMAT
    ON SCHEMA RAW_DB.SAKILA TO ROLE DEVELOPMENT_ROLE;

-- --- Grants: existing objects (tables already synced by Airbyte) ---
GRANT SELECT ON ALL TABLES IN SCHEMA RAW_DB.PAGILA TO ROLE DEVELOPMENT_ROLE;
GRANT SELECT ON ALL TABLES IN SCHEMA RAW_DB.SAKILA TO ROLE DEVELOPMENT_ROLE;

-- --- Grants: future objects (tables & views created by Airbyte/dbt) ---
GRANT ALL PRIVILEGES ON FUTURE TABLES IN SCHEMA RAW_DB.PAGILA TO ROLE DEVELOPMENT_ROLE;
GRANT ALL PRIVILEGES ON FUTURE TABLES IN SCHEMA RAW_DB.SAKILA TO ROLE DEVELOPMENT_ROLE;
GRANT ALL PRIVILEGES ON FUTURE VIEWS  IN SCHEMA RAW_DB.PAGILA TO ROLE DEVELOPMENT_ROLE;
GRANT ALL PRIVILEGES ON FUTURE VIEWS  IN SCHEMA RAW_DB.SAKILA TO ROLE DEVELOPMENT_ROLE;

-- Service user (replace password before running; never commit real password to git)
CREATE OR REPLACE USER AIRFLOW_DEV_USER
    PASSWORD          = 'REPLACE_WITH_STRONG_PASSWORD'
    DEFAULT_ROLE      = DEVELOPMENT_ROLE
    DEFAULT_WAREHOUSE = COMPUTE_WH
    COMMENT           = 'Service account for Airbyte, Airflow, dbt';

GRANT ROLE DEVELOPMENT_ROLE TO USER AIRFLOW_DEV_USER;


-- =============================================================================
-- PART B — GRANTS REPAIR (SAFE TO RE-RUN)
-- =============================================================================
-- Run this block when:
--   - Airbyte error: "CREATE SCHEMA granted on DATABASE RAW_DB"
--   - Airbyte error: permission denied on STAGE / FILE FORMAT
--   - Starting dbt and models fail with access errors
--   - You added a new schema and need to extend grants
--
-- Does NOT use CREATE OR REPLACE — existing data is untouched.

USE ROLE ACCOUNTADMIN;

-- Warehouse
GRANT USAGE   ON WAREHOUSE COMPUTE_WH TO ROLE DEVELOPMENT_ROLE;
GRANT MONITOR ON WAREHOUSE COMPUTE_WH TO ROLE DEVELOPMENT_ROLE;

-- Database
GRANT USAGE        ON DATABASE RAW_DB TO ROLE DEVELOPMENT_ROLE;
GRANT CREATE SCHEMA ON DATABASE RAW_DB TO ROLE DEVELOPMENT_ROLE;

-- Schemas: PAGILA
GRANT USAGE ON SCHEMA RAW_DB.PAGILA TO ROLE DEVELOPMENT_ROLE;
GRANT CREATE TABLE, CREATE VIEW, CREATE STAGE, CREATE FILE FORMAT
    ON SCHEMA RAW_DB.PAGILA TO ROLE DEVELOPMENT_ROLE;
GRANT SELECT ON ALL TABLES IN SCHEMA RAW_DB.PAGILA TO ROLE DEVELOPMENT_ROLE;
GRANT ALL PRIVILEGES ON FUTURE TABLES IN SCHEMA RAW_DB.PAGILA TO ROLE DEVELOPMENT_ROLE;
GRANT ALL PRIVILEGES ON FUTURE VIEWS  IN SCHEMA RAW_DB.PAGILA TO ROLE DEVELOPMENT_ROLE;

-- Schemas: SAKILA
GRANT USAGE ON SCHEMA RAW_DB.SAKILA TO ROLE DEVELOPMENT_ROLE;
GRANT CREATE TABLE, CREATE VIEW, CREATE STAGE, CREATE FILE FORMAT
    ON SCHEMA RAW_DB.SAKILA TO ROLE DEVELOPMENT_ROLE;
GRANT SELECT ON ALL TABLES IN SCHEMA RAW_DB.SAKILA TO ROLE DEVELOPMENT_ROLE;
GRANT ALL PRIVILEGES ON FUTURE TABLES IN SCHEMA RAW_DB.SAKILA TO ROLE DEVELOPMENT_ROLE;
GRANT ALL PRIVILEGES ON FUTURE VIEWS  IN SCHEMA RAW_DB.SAKILA TO ROLE DEVELOPMENT_ROLE;

-- User ↔ role binding (idempotent)
GRANT ROLE DEVELOPMENT_ROLE TO USER AIRFLOW_DEV_USER;
ALTER USER AIRFLOW_DEV_USER SET DEFAULT_ROLE      = DEVELOPMENT_ROLE;
ALTER USER AIRFLOW_DEV_USER SET DEFAULT_WAREHOUSE = COMPUTE_WH;


-- =============================================================================
-- PART C — VERIFY (read-only, run anytime)
-- =============================================================================
-- Run after Part A or B to confirm everything is in place.
-- Select only this block and press Run.

USE ROLE ACCOUNTADMIN;

-- Objects exist?
SHOW WAREHOUSES LIKE 'COMPUTE_WH';
SHOW DATABASES  LIKE 'RAW_DB';
SHOW SCHEMAS IN DATABASE RAW_DB;

-- Role and user exist?
SHOW ROLES LIKE 'DEVELOPMENT_ROLE';
SHOW USERS  LIKE 'AIRFLOW_DEV_USER';

-- Grants applied?
SHOW GRANTS TO ROLE DEVELOPMENT_ROLE;
SHOW GRANTS TO USER AIRFLOW_DEV_USER;

-- Data landed? (switch to service role to simulate pipeline access)
USE ROLE DEVELOPMENT_ROLE;
USE WAREHOUSE COMPUTE_WH;

SHOW TABLES IN SCHEMA RAW_DB.PAGILA;
SHOW TABLES IN SCHEMA RAW_DB.SAKILA;

SELECT 'pagila_films' AS check_name, COUNT(*) AS row_count FROM RAW_DB.PAGILA.FILM
UNION ALL
SELECT 'sakila_films', COUNT(*) FROM RAW_DB.SAKILA.FILM;
