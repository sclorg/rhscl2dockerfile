#!/bin/bash

. "/usr/share/cont-lib/cont-lib.sh"

set -e

if [ "$1" == "--debug" ] ; then
    echo "---> Debugging mode for {{ name }} container"
    exec /bin/bash
fi

cont_source_hooks run sti
