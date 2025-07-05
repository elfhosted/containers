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
    current_theme="$(xmlstarlet sel -t -v "//Theme" -nl /config/config.xml)"
fi

# Update config.xml with environment variables
envsubst < /app/config.xml.tmpl > /config/config.xml

# Override configuation values from existing config.xml if there are no LIDARR__ variables set
[[ -z "${LIDARR__LOG_LEVEL}" && -n "${current_log_level}" ]] && xmlstarlet edit --inplace --update //LogLevel -v "${current_log_level}" /config/config.xml
[[ -z "${LIDARR__URL_BASE}" && -n "${current_url_base}" ]] && xmlstarlet edit --inplace --update //UrlBase -v "${current_url_base}" /config/config.xml
[[ -z "${LIDARR__BRANCH}" && -n "${current_branch}" ]] && xmlstarlet edit --inplace --update //Branch -v "${current_branch}" /config/config.xml
[[ -z "${LIDARR__ANALYTICS_ENABLED}" && -n "${current_analytics_enabled}" ]] && xmlstarlet edit --inplace --update //AnalyticsEnabled -v "${current_analytics_enabled}" /config/config.xml
[[ -z "${LIDARR__API_KEY}" && -n "${current_api_key}" ]] && xmlstarlet edit --inplace --update //ApiKey -v "${current_api_key}" /config/config.xml
[[ -z "${LIDARR__AUTHENTICATION_METHOD}" && -n "${current_authentication_method}" ]] && xmlstarlet edit --inplace --update //AuthenticationMethod -v "${current_authentication_method}" /config/config.xml
[[ -z "${LIDARR__AUTHENTICATION_REQUIRED}" && -n "${current_authentication_required}" ]] && xmlstarlet edit --inplace --update //AuthenticationRequired -v "${current_authentication_required}" /config/config.xml
[[ -z "${LIDARR__INSTANCE_NAME}" && -n "${current_instance_name}" ]] && xmlstarlet edit --inplace --update //InstanceName -v "${current_instance_name}" /config/config.xml
[[ -z "${LIDARR__POSTGRES_USER}" && -n "${current_postgres_user}" ]] && xmlstarlet edit --inplace --update //PostgresUser -v "${current_postgres_user}" /config/config.xml
[[ -z "${LIDARR__POSTGRES_PASSWORD}" && -n "${current_postgres_password}" ]] && xmlstarlet edit --inplace --update //PostgresPassword -v "${current_postgres_password}" /config/config.xml
[[ -z "${LIDARR__POSTGRES_PORT}" && -n "${current_postgres_port}" ]] && xmlstarlet edit --inplace --update //PostgresPort -v "${current_postgres_port}" /config/config.xml
[[ -z "${LIDARR__POSTGRES_HOST}" && -n "${current_postgres_host}" ]] && xmlstarlet edit --inplace --update //PostgresHost -v "${current_postgres_host}" /config/config.xml
[[ -z "${LIDARR__POSTGRES_MAIN_DB}" &&  -n "${current_postgres_main_db}" ]] && xmlstarlet edit --inplace --update //PostgresMainDb -v "${current_postgres_main_db}" /config/config.xml
[[ -z "${LIDARR__POSTGRES_LOG_DB}" && -n "${current_postgres_log_db}" ]] && xmlstarlet edit --inplace --update //PostgresLogDb -v "${current_postgres_log_db}" /config/config.xml
[[ -z "${LIDARR__THEME}" && -n "${current_theme}" ]] && xmlstarlet edit --inplace --update //Theme -v "${current_theme}" /config/config.xml

# BindAddress, LaunchBrowser, Port, EnableSsl, SslPort, SslCertPath, SslCertPassword, UpdateMechanism
# have been omited because their configuration is not really needed in a container environment

# Set the host to nothing for now
xmlstarlet edit --inplace --update //PostgresHost -v "" /config/config.xml

# BindAddress, LaunchBrowser, Port, EnableSsl, SslPort, SslCertPath, SslCertPassword, UpdateMechanism
# have been omited because their configuration is not really needed in a container environment

if [[ "${USE_POSTGRESQL:-"false"}" == "true" ]]; then

    # Update the host if we're using postgres
    xmlstarlet edit --inplace --update //PostgresHost -v "${LIDARR__POSTGRES_HOST}" /config/config.xml

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

    if [[ -f /config/i-am-bootstrapped && -f /config/lidarr.db ]]; then
        echo "Migrating to postgresql database..."
        
        # Create databases
        psql -c "DROP DATABASE IF EXISTS lidarr_main;" && psql -c "CREATE DATABASE lidarr_main;" && psql -c "ALTER DATABASE lidarr_main OWNER TO lidarr;"
        psql -c "DROP DATABASE IF EXISTS lidarr_logs;" && psql -c "CREATE DATABASE lidarr_logs;" && psql -c "ALTER DATABASE lidarr_logs OWNER TO lidarr;"
  
        # Start lidarr to force the database schemas to be created
        timeout 60s /app/bin/Lidarr \
                --nobrowser \
                --data=/config

        # Dump DB schemas
        echo "Dumbing DB schemas..."
        pg_dump --schema-only -d lidarr_main > /tmp/lidarr_main_schema.sql

        # Recreate database from schemas
        echo "Recreating databases..."
        psql -c "DROP DATABASE IF EXISTS lidarr_main;" && psql -c "CREATE DATABASE lidarr_main;" && psql -c "ALTER DATABASE lidarr_main OWNER TO lidarr;" && psql -d lidarr_main -f /tmp/lidarr_main_schema.sql

        # Import sqlite data
        echo "Importing SQLite databases..."
        POSTGRES_CONN_STRING=postgres://lidarr:lidarr@localhost/lidarr_main?sslmode=disable SQLITE_CONN_STRING=/config/lidarr.db importarr

        # Move sqlite files into migrated folder
        echo "Archiving SQLite databases"
        mkdir -p /config/migrated-to-postgres
        mv /config/lidarr.db /config/migrated-to-postgres
        
        echo "Migration done, starting application..."
    else
        echo "Migration already done (we are bootstrapped but no sqlite DBs exist)"
    fi
fi

#shellcheck disable=SC2086
exec \
    /app/bin/Lidarr \
        --nobrowser \
        --data=/config \
        "$@"
