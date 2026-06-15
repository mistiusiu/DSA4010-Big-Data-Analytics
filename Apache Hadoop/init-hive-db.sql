-- Connect to the metastore database
\c metastore_db;

-- Ensure the hive user owns the database and has public schema rights
ALTER DATABASE metastore_db OWNER TO hive;
GRANT ALL PRIVILEGES ON DATABASE metastore_db TO hive;

-- Fix for PostgreSQL 15+ public schema security restrictions
GRANT USAGE, CREATE ON SCHEMA public TO hive;
