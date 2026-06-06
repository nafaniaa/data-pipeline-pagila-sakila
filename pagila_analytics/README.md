# pagila_analytics

dbt project for transforming `RAW_DB.PAGILA` raw tables into analytics models.

## Setup

1. Copy the profile template and set your Snowflake password:

```powershell
copy profiles.example.yml profiles.yml
# Edit profiles.yml — replace REPLACE_WITH_YOUR_PASSWORD
```

2. Ensure schema exists in Snowflake (run once as ACCOUNTADMIN):

```sql
CREATE SCHEMA IF NOT EXISTS RAW_DB.ANALYTICS;
GRANT ALL PRIVILEGES ON SCHEMA RAW_DB.ANALYTICS TO ROLE DEVELOPMENT_ROLE;
GRANT ALL PRIVILEGES ON FUTURE TABLES IN SCHEMA RAW_DB.ANALYTICS TO ROLE DEVELOPMENT_ROLE;
GRANT ALL PRIVILEGES ON FUTURE VIEWS IN SCHEMA RAW_DB.ANALYTICS TO ROLE DEVELOPMENT_ROLE;
```

3. Test connection (profile is in this project folder):

```powershell
dbt debug --profiles-dir .
```

4. Run models:

```powershell
dbt run --profiles-dir .
dbt test --profiles-dir .
```
