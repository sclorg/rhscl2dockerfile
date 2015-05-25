# OpenShift specific configuration

if [ -n "$MONGODB_NOPREALLOC" ]; then
    update_option noprealloc $MONGODB_NOPREALLOC $mongod_config_file
fi

if [ -n "$MONGODB_SMALLFILES" ]; then
    update_option smallfiles $MONGODB_SMALLFILES $mongod_config_file
fi

if [ -n "$MONGODB_QUIET" ]; then
    update_option quiet $MONGODB_QUIET $mongod_config_file
fi

MONGODB_AUTH=false

if [ ! -f /var/lib/mongodb/data/.mongodb_users_created ]; then

    if [ -z "${MONGODB_USER}" -o -z "${MONGODB_PASSWORD}" -o -z "${MONGODB_DATABASE}" -o -z "${MONGODB_ADMIN_PASSWORD}" ]; then
        # Print container-usage and exit
        container-usage
        exit 1
    fi

    MONGODB_AUTH=true
fi
