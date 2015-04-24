[mysqld]
datadir=/var/lib/mysql/data
socket=/var/lib/mysql/mysql.sock

# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0

[mysqld_safe]
log-error={{ logfile }}
pid-file={{ pidfile }}

#
# include all files from the config directory
#
!includedir /etc/my.cnf.d
