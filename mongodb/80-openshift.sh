# OpenShift specific configuration

if [ "${MONGODB_AUTH}" = "true" ]; then
    # Succeeded to create users 
    MONGODB_AUTH=false

    touch /var/lib/mongodb/data/.mongodb_users_created
fi

update_option auth "true" $mongod_config_file
