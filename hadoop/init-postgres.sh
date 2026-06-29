#!/bin/bash
set -e

# 1. Apply optimizations and fixes to the default metastore_db
echo "Configuring schema permissions on metastore_db..."
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    ALTER DATABASE metastore_db OWNER TO hive;
    GRANT ALL PRIVILEGES ON DATABASE metastore_db TO hive;
    GRANT USAGE, CREATE ON SCHEMA public TO hive;
EOSQL

# 2. Programmatically spawn the secondary database for Hue Metadata tracking
echo "Creating dedicated storage space for hue_metadata..."
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE hue_metadata;
    GRANT ALL PRIVILEGES ON DATABASE hue_metadata TO hive;
EOSQL

# 3. Patch PostgreSQL 15+ public schema restrictions on the newly generated Hue database
echo "Configuring schema permissions on hue_metadata..."
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "hue_metadata" <<-EOSQL
    ALTER DATABASE hue_metadata OWNER TO hive;
    GRANT USAGE, CREATE ON SCHEMA public TO hive;
EOSQL

echo "PostgreSQL database structures initialized successfully."
