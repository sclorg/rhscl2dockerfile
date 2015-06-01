#!/bin/bash

. "/usr/share/cont-lib/cont-lib.sh"

set -e

if [ "$1" = "-h" ]; then
    exec /usr/share/sti/usage
fi

echo "---> Installing application source"
cp -Rf /tmp/src/. ./

echo "---> Building your {{ name }} application from source"
cont_source_hooks assemble sti
