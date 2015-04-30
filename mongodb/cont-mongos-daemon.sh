#!/bin/bash

# this function sources *.sh in the following directories in this order:
# /usr/share/cont-layer/$1/$2.d
# /usr/share/cont-volume/$1/$2.d
source_scripts() {
    [ -z "$2" ] && return
    for dir in cont-layer cont-volume ; do
        full_dir="/usr/share/$dir/${1}/${2}.d"
        for i in ${full_dir}/*.sh; do
            if [ -r "$i" ]; then
                . "$i"
            fi
        done
    done
}

# Wait_mongo waits until the mongo server is up/down
function wait_mongo() {
    operation=-eq
    if [ $1 = "DOWN" -o $1 = "down" ]; then
        operation=-ne
    fi

    local mongo_cmd="mongo admin --host ${2:-localhost:$port} "

    for i in $(seq $MAX_ATTEMPTS); do
        echo "=> ${mongo_host} Waiting for MongoDB daemon $1"
        set +e
        $mongo_cmd --eval "quit()" &>/dev/null
        status=$?
        set -e
        if [ $status $operation 0 ]; then
            echo "=> MongoDB daemon is $1"
            return 0
        fi
        sleep $SLEEP_TIME
    done
    echo "=> Giving up: MongoDB daemon is not $1!"
    exit 1
}

# Shutdown mongod on SIGINT/SIGTERM
function cleanup() {
    echo "=> Shutting down MongoDB server"
    if [ -s $pidfile ]; then
        set +e
        kill $(cat $pidfile)
        set -e
    fi
    wait_mongo "DOWN"
    status=$?

    if [ $status -ne 0 -a -s $pidfile ]; then
        set +e
        kill -9 $(cat $pidfile)
        set -e
        wait_mongo "DOWN"
    fi

    exit 0
}

MAX_ATTEMPTS=90
SLEEP_TIME=2

mongos_config_file="/etc/mongos.conf"

# Change config file according MONGOS_CONFIG_* variables
for option in $(set | grep MONGOS_CONFIG | sed -r -e 's|MONGOS_CONFIG_||'); do
    # Delete old option from config file
    option_name=$(echo $option | sed -r -e 's|(\w*)=.*|\1|')
    sed -r -e "/^$option_name/d" $mongos_config_file > $HOME/.mongos.conf
    cat $HOME/.mongos.conf > $mongos_config_file
    rm $HOME/.mongos.conf
    # Add new option into config file
    echo $option >> $mongos_config_file
done

# Get options from config file
pidfile=$(grep '^\s*pidfilepath' $mongos_config_file | sed -r -e 's|^\s*pidfilepath\s*=\s*||')

# Get used port
port=$(grep '^\s*port' $mongos_config_file | sed -r -e 's|^\s*port\s*=\s*(\d*)|\1|')
port=${port:-27017}

trap 'cleanup' SIGINT SIGTERM

# Run scripts before mongod start
source_scripts mongodb pre-init

# Add default config file
mongo_common_args="-f $mongos_config_file "
mongo_local_args="--bind_ip localhost "

# Start background MongoDB service with disabled authentication
mongos $mongo_common_args $mongo_local_args &
wait_mongo "UP"

# Run scripts with started mongod
source_scripts mongodb init

# Stop background MongoDB service to exec mongos
set +e
kill $(cat $pidfile)
set -e
wait_mongo "DOWN"
status=$?

if [ $status -ne 0]; then
    set +e
    kill -9 $(cat $pidfile)
    set -e
    wait_mongo "DOWN"
fi


# Run scripts after mongod stoped
source_scripts mongodb post-init

# Start MongoDB service with enabled authentication
exec mongos $mongo_common_args
