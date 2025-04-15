#!/usr/bin/env bash

#shellcheck disable=SC1091
test -f "/scripts/umask.sh" && source "/scripts/umask.sh"

# Discover existing configuration settings for backwards compatibility
if [[ -f /config/config.xml ]]; then
    current_log_level="$(xmlstarlet sel -t -v "//LogLevel" -nl /config/config.xml)"
    current_url_base="$(xmlstarlet sel -t -v "//UrlBase" -nl /config/config.xml)"
    current_branch="$(xmlstarlet sel -t -v "//Branch" -nl /config/config.xml)"
    current_analytics_enabled="$(xmlstarlet sel -t -v "//AnalyticsEnabled" -nl /config/config.xml)"
    current_api_key="$(xmlstarlet sel -t -v "//ApiKey" -nl /config/config.xml)"
    current_authentication_method="$(xmlstarlet sel -t -v "//AuthenticationMethod" -nl /config/config.xml)"
    current_authentication_required="$(xmlstarlet sel -t -v "//AuthenticationRequired" -nl /config/config.xml)"
    current_instance_name="$(xmlstarlet sel -t -v "//InstanceName" -nl /config/config.xml)"
    current_postgres_user="$(xmlstarlet sel -t -v "//PostgresUser" -nl /config/config.xml)"
    current_postgres_password="$(xmlstarlet sel -t -v "//PostgresPassword" -nl /config/config.xml)"
    current_postgres_port="$(xmlstarlet sel -t -v "//PostgresPort" -nl /config/config.xml)"
    current_postgres_host="$(xmlstarlet sel -t -v "//PostgresHost" -nl /config/config.xml)"
    current_postgres_main_db="$(xmlstarlet sel -t -v "//PostgresMainDb" -nl /config/config.xml)"
    current_postgres_log_db="$(xmlstarlet sel -t -v "//PostgresLogDb" -nl /config/config.xml)"
fi

# Update config.xml with environment variables
envsubst < /app/config.xml.tmpl > /config/config.xml

# Override configuation values from existing config.xml if there are no SONARR__ variables set
[[ -z "${SONARR__LOG_LEVEL}" && -n "${current_log_level}" ]] && xmlstarlet edit --inplace --update //LogLevel -v "${current_log_level}" /config/config.xml
[[ -z "${SONARR__URL_BASE}" && -n "${current_url_base}" ]] && xmlstarlet edit --inplace --update //UrlBase -v "${current_url_base}" /config/config.xml
[[ -z "${SONARR__BRANCH}" && -n "${current_branch}" ]] && xmlstarlet edit --inplace --update //Branch -v "${current_branch}" /config/config.xml
[[ -z "${SONARR__ANALYTICS_ENABLED}" && -n "${current_analytics_enabled}" ]] && xmlstarlet edit --inplace --update //AnalyticsEnabled -v "${current_analytics_enabled}" /config/config.xml
[[ -z "${SONARR__API_KEY}" && -n "${current_api_key}" ]] && xmlstarlet edit --inplace --update //ApiKey -v "${current_api_key}" /config/config.xml
[[ -z "${SONARR__AUTHENTICATION_METHOD}" && -n "${current_authentication_method}" ]] && xmlstarlet edit --inplace --update //AuthenticationMethod -v "${current_authentication_method}" /config/config.xml
[[ -z "${SONARR__AUTHENTICATION_REQUIRED}" && -n "${current_authentication_required}" ]] && xmlstarlet edit --inplace --update //AuthenticationRequired -v "${current_authentication_required}" /config/config.xml
[[ -z "${SONARR__INSTANCE_NAME}" && -n "${current_instance_name}" ]] && xmlstarlet edit --inplace --update //InstanceName -v "${current_instance_name}" /config/config.xml
[[ -z "${SONARR__POSTGRES_USER}" && -n "${current_postgres_user}" ]] && xmlstarlet edit --inplace --update //PostgresUser -v "${current_postgres_user}" /config/config.xml
[[ -z "${SONARR__POSTGRES_PASSWORD}" && -n "${current_postgres_password}" ]] && xmlstarlet edit --inplace --update //PostgresPassword -v "${current_postgres_password}" /config/config.xml
[[ -z "${SONARR__POSTGRES_PORT}" && -n "${current_postgres_port}" ]] && xmlstarlet edit --inplace --update //PostgresPort -v "${current_postgres_port}" /config/config.xml
[[ -z "${SONARR__POSTGRES_MAIN_DB}" &&  -n "${current_postgres_main_db}" ]] && xmlstarlet edit --inplace --update //PostgresMainDb -v "${current_postgres_main_db}" /config/config.xml
[[ -z "${SONARR__POSTGRES_LOG_DB}" && -n "${current_postgres_log_db}" ]] && xmlstarlet edit --inplace --update //PostgresLogDb -v "${current_postgres_log_db}" /config/config.xml


# Set the host to nothing for now
xmlstarlet edit --inplace --update //PostgresHost -v "" /config/config.xml


# Perform migrations if desired
# 1 use /tmp to get the current schema by using fake preferences in /tmp and running for 1 min
# 2 import sqlite databases into postgres
# 3 move sqlite databases to indicate they've been migrated
# 4 start normally

if [[ "${USE_POSTGRESQL:-"false"}" == "true" ]]; then

    xmlstarlet edit --inplace --update //PostgresHost -v "localhost" /config/config.xml
    # Make sure config is updated for postgres

    if [[ -f /config/i-am-bootstrapped && -f /config/sonarr.db ]]; then
        echo "Migrating to postgresql database..."

        # Function to check PostgreSQL connection
        function pg_is_ready() {
        psql -h $PGHOST -U $PGUSER -d $PGDATABASE -c "SELECT 1" >/dev/null 2>&1
        return $?
        }

        # Wait for PostgreSQL to be ready
        echo "Waiting for PostgreSQL to be ready..."
        until pg_is_ready; do
        echo "PostgreSQL is unavailable - sleeping for 5 seconds"
        sleep 5
        done

        # Create databases
        psql -c "CREATE DATABASE sonarr_logs;" || true && psql -c "ALTER DATABASE sonarr_logs OWNER TO sonarr;"
        psql -c "CREATE DATABASE sonarr_main;" || true && psql -c "ALTER DATABASE sonarr_main OWNER TO sonarr;"
                
        # Start sonarr to force the database schemas to be created
        timeout 60s /app/Sonarr \
                --nobrowser \
                --data=/config

        # Dump DB schemas
        echo "Dumbing DB schemas..."
        pg_dump --schema-only -d sonarr_main > /tmp/sonarr_main_schema.sql
        # pg_dump --schema-only -d sonarr_logs > /tmp/sonarr_logs_schema.sql

        # Recreate database from schemas
        echo "Recreating databases..."
        psql -c "DROP DATABASE IF EXISTS sonarr_main;" && psql -c "CREATE DATABASE sonarr_main;" && psql -c "ALTER DATABASE sonarr_main OWNER TO sonarr;" && psql -d sonarr_main -f /tmp/sonarr_main_schema.sql
        # psql -c "DROP DATABASE IF EXISTS sonarr_logs;" && psql -c "CREATE DATABASE sonarr_logs;" && psql -c "ALTER DATABASE sonarr_logs OWNER TO sonarr;" && psql -d sonarr_logs -f /tmp/sonarr_logs_schema.sql

        # Import sqlite data
        echo "Importing SQLite databases..."
        POSTGRES_CONN_STRING=postgres://sonarr:sonarr@localhost/sonarr_main?sslmode=disable SQLITE_CONN_STRING=/config/sonarr.db importarr
        # POSTGRES_CONN_STRING=postgres://sonarr:sonarr@localhost/sonarr_logs?sslmode=disable SQLITE_CONN_STRING=/config/logs.db importarr

        # Move sqlite files into migrated folder
        echo "Archiving SQLite databases"
        mkdir -p /config/migrated-to-postgres
        mv /config/sonarr.db /config/migrated-to-postgres
        
        echo "Migration done, starting application..."
    else
        echo "Migration already done (we are bootstrapped but no sqlite DBs exist)"
    fi
fi



# BindAddress, LaunchBrowser, Port, EnableSsl, SslPort, SslCertPath, SslCertPassword, UpdateMechanism
# have been omited because their configuration is not really needed in a container environment

if [[ "${SONARR__LOG_LEVEL}" == "debug" || "${current_log_level}" == "debug" ]]; then
    echo "Starting with the following configuration..."
    xmlstarlet format --omit-decl /config/config.xml
fi

#shellcheck disable=SC2086
exec \
    /app/Sonarr \
        --nobrowser \
        --data=/config \
        "$@"