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

    [[ -z "${SONARR__POSTGRES_HOST}" && -n "${current_postgres_host}" ]] && xmlstarlet edit --inplace --update //PostgresHost -v "${current_postgres_host}" /config/config.xml
    # Make sure config is updated for postgres

    if [[ -f /config/i-am-bootstrapped && -f /config/logs.db && -f /config/sonarr.db ]]; then
        echo "Migrating to postgresql database..."

        # Function to check PostgreSQL connection
        function pg_is_ready() {
        PGPASSWORD=$PGPASSWORD psql -h $PGHOST -p $PGPORT -U $PGUSER -d $PGDATABASE -c "SELECT 1" >/dev/null 2>&1
        return $?
        }

        # Wait for PostgreSQL to be ready
        echo "Waiting for PostgreSQL to be ready..."
        until pg_is_ready; do
        echo "PostgreSQL is unavailable - sleeping for 1 second"
        sleep 1
        done

        # Create logs database if it doesn't exist
        psql -c "SELECT 'CREATE DATABASE logs; ALTER DATABASE logs OWNER TO sonarr;' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'logs')\gexec"

        # Start sonarr to force the database schemas to be created
        timeout 60s exec \
            /app/Sonarr \
                --nobrowser \
                --data=/config \
                "$@"

        # empty the databases of any initial data which would conflict with our import
        psql -d radarr -c "DO \$\$ BEGIN EXECUTE (SELECT 'TRUNCATE TABLE ' || string_agg(quote_ident(tablename), ', ') || ' CASCADE' FROM pg_tables WHERE schemaname = 'public'); END \$\$;"
        psql -d logs -c "DO \$\$ BEGIN EXECUTE (SELECT 'TRUNCATE TABLE ' || string_agg(quote_ident(tablename), ', ') || ' CASCADE' FROM pg_tables WHERE schemaname = 'public'); END \$\$;"

        # Import sqlite data
        pgloader --with "quote identifiers" --with "data only" /config/sonarr.db "postgresql://sonarr:sonarr@localhost/sonarr"
        pgloader --with "quote identifiers" --with "data only" /config/logs.db "postgresql://sonarr:sonarr@localhost/logs"

        # Move sqlite files into migrated folder
        mkdir -p /config/migrated-to-postgres
        mv /config/sonarr.db /config/logs.db /config/migrated-to-postgres
        
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