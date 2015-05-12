#!/bin/bash

# TODO: support API for executable help scripts
cat /usr/share/cont-docs/*.txt 2>/dev/null

cat <<EOF

======================
General container help
======================

Run 'docker run THIS_IMAGE{% if 'container-usage' not in cmd %} container-usage{% endif %}' to get this help.

Run 'docker run -ti THIS_IMAGE bash' to obtain interactive shell.

Run 'docker exec -ti CONTAINERID bash' to access already running container.

You may try '-e CONT_DEBUG=VAL' with VAL up to 3 to get more verbose debugging
info.
EOF
