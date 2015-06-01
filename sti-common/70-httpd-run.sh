# Often sti script executes httpd daemon in the end to provide HTTP service
# Use this drop-in file in case you need to start httpd daemon
# Typical usage is copying this file as the last script into
# /usr/share/cont-lib/sti/run/

exec httpd -D FOREGROUND

