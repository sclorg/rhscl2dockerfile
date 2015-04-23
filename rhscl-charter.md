RHSCL docker images charter
===========================
Reasoning: This document should serve as agreement what users may expect from docker images based on RHSCL packages.


Common requirements for all RHSCL docker images:
------------------------------------------------
The following information is valid for all RHSCL dockerfiles.

### Base images

What will be used in the docker images as the base image:
* `FROM rhel7` is used for RHEL-7 based images
* `FROM centos:centos7` is used for centos-7 based images
* `FROM rhel6` is used for RHEL-6 based images
* `FROM centos:centos6` is used for centos-6 based images


### Repositories enabled in the image

For installing necessary packages, the following repositories are enabled for RHEL-based images:
````
RUN yum update -y && yum install -y yum-utils && \
    yum-config-manager --enable rhel-server-rhscl-7-rpms && \
    yum-config-manager --enable rhel-7-server-optional-rpms
````

These repos will be enabled for CentOS images:
```
RUN rpmkeys --import file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
    (+ copr repository RPM packages for all necessary Software Collections that are installed)
```


### Labels and temporary environment variables:

TODO: this is to be decided; OpenShift uses IMAGE_TAGS, IMAGE_EXPOSE_SERVICES and other ENV variables, which should serve for the same purpose as LABELs in the future docker versions, but we need to document what is the expected content, why there are defined and how the transition to LABEL will look like


### Enabling the collection:

What happends when running the dockerfile with 'bash' as command:
```
docker run <imagename> bash
```
Bash is run with all necessary collections enabled (usually one, but for some images more).

Collection is enabled in entrypoint and it is also the only thing done in the entrypoint.

To run the docker container without collection enabled, it can be done by changing --entrypoint to sh -c.

If we run the `docker exec <imagename> bash` the collection also has to be enabled. (mind that entrypoint is not run in this case, so the collection has to be enabled somewhere else than in entrypoint).


Common requirements for all language stacks docker images:
----------------------------------------------------------

### Devel packages installed:

In order to be able to build some modules from upstream repository, some devel packages are usually necessary. The following list may be the same for all language stack dockerfiles.

```bash
RUN yum install -y --setopt=tsflags=nodocs \
    autoconf \
    automake \
    bsdtar \
    curl-devel \
    epel-release \
    gcc-c++ \
    gdb \
    gettext \
    libxml2-devel \
    libxslt-devel \
    lsof \
    make \
    mysql-devel \
    mysql-libs \
    openssl-devel \
    postgresql-devel \
    procps-ng \
    scl-utils \
    sqlite-devel \
    tar \
    unzip \
    wget \
    which \
    yum-utils \
    zlib-devel && \
    yum clean all -y
```

### default user and its home directory

(This is just a proposal and this issue is being consulted at https://lists.fedoraproject.org/pipermail/env-and-stacks/2015-April/000771.html)

The application shouldn't run as root, so we need to create a user for containers that don't provide a specific user yet. (some packages like deamons do provide those users already, so those should be used)

```
ENV HOME /home/default
# Setup the 'default' user that is used for the build execution and for the
# application runtime execution.
# TODO: Use better UID and GID values
RUN mkdir -p ${HOME} && \
    groupadd -r default -f -g 333 && \
    useradd -u 333 -r -g default -d ${HOME} -s /sbin/nologin \
            -c "Default Application User" default
```

### Exposing ports

If there is a port that is usually used for development or production, this port should be exposed in the Dockerfile.
EXPOSE <develport>


### php dockerfile:
EXPOSE 8080
extra packages: TODO


### python dockerfile:
extra packages: python33-python-devel python33-python-setuptools
EXPOSE 8080


### ruby dockerfile:
collections: ror40 ruby200
extra packages: ruby200-ruby-devel ruby200-rubygem-rake v8314 ror40-rubygem-bundler ror40-rubygem-rack
EXPOSE 8080 (TODO: not 5000?)


### nodejs dockerfile:
EXPOSE 8080


### perl dockerfile:
EXPOSE 8080
extra packages: perl516-mod_perl perl516-perl-CPANPLUS


Common requirements for daemons:
--------------------------------
After running the container without any command, the daemon is run using exec (no other process is forking to run the daemon) -- this is necessary to pass signals properly

Daemon is listening on 0.0.0.0.

Data directory (if any) that is expected to be mounted shouldn't be home directory of user, there may be more stuff that we don't want to mount, so in some cases we use data/ subdirectory for data themselves (and VOLUME)

### Extending the docker images:

In order to allow just extending the docker image easily without rewriting scripts from scratch, the scripts should include hook scripts in places it makes sense from directory that may be mounted or extended in another layer, something similar to the following (for databases the hooks may be "preinit", "postinit"):

```
source_scripts() {
    [ -z "$1" ] && return
    for i in $1/*.sh; do
        if [ -r "$i" ]; then
            . "$i"
        fi
    done
}
source_scripts /usr/share/cont-layer/mysql/post-initdb.d
source_scripts /usr/share/cont-volume/mysql/post-initdb.d
```

So the image that extends such an image will just place some Bash scripts into `/usr/share/cont-layer/mysql/post-initdb.d` directory and won't need to change anything else.


### Config files modification:

When possible, config files should be modified by creating another layer (container with the original used as BASE)

For ad-hoc changing the values it is then possible to change the config file by mounting a volume (directory or file). For example for mysql the configuration may be changed for every run this way:
```
docker run -v /mine/my.cnf:/etc/my.cnf mysql
```

For kubernetes environment, where mounting configuration is not easy right now, docker containers will accept environment variables, that will (if defined) cause adding appropriate option to the appropriate config file during start. These environment variables won't be documented and will be used only in cases the configuration is not possible to be changed by mounting a volume as mentioned above (e.g. OpenShift needs to pass environment variables only).

The environemtn variables will have common prefix for every configuration file, for example:

POSTGRESQL_CONFIG for postgresql.conf
MYSQL_CONFIG for my.cnf
MONGOD_CONFIG for mongod.conf
MONGOS_CONFIG for mongos.conf

Then user may define the following variables during container start:

POSTGRESQL_CONF_SHARED_BUFFERS=true
MYSQL_CONF_FT_MIN_WORD_LEN=4
MONGODB_CONF_SMALL_FILES=1
MONGODB_CONF_SHARD_SMALL_FILES=1

Defining those variables will cause:

adding shared_buffers=true into postgresql.conf
adding ft_min_word_len=4 into my.cnf
adding smallfiles=true into mongod.conf
adding smallfiles=true into mongos.conf


### mariadb/mysql dockerfiles:

* `mysql` user must have UID 27, GID 27
* Binaries that must be available in the shell: `mysqld`, `mysql`, `mysqladmin`
* Available commands within container:
  * `run-mysqld` (default CMD)
* Exposed port: 3306
* Directory for data (VOLUME): /var/lib/mysql/data
* Config file: /etc/my.cnf, /etc/my.cnf.d
* Deamon runs as `mysql` user (`USER` directive)
* Log file directory: `/var/log/<package>`, e.g. `/var/log/mariadb`
* Socket file: not necessary, if proofed otherwise, `/var/lib/mysql/mysql.sock` will be used
* Environment variables:
  * MYSQL_USER - Database user name
  * MYSQL_PASSWORD - User's password
  * MYSQL_DATABASE - Name of the database to create
  * MYSQL_ROOT_PASSWORD - Password for the 'root' MySQL account
  * either root_password or user+password+database must be set if running with empty datadir, both combination is also valid
  * MYSQL_DISABLE_CREATE_DB -- when set, it disables initializing DB and no other variables from the set above is required


### postgresql dockerfile:

* Binaries that must be available in the shell: `psql`, `postmaster`, `pg_ctl`
* Available commands within container:
  * `run-postgresql` (default CMD)
* Exposed port: 5432
* Directory for data (VOLUME): /var/lib/pgsql/data ($PGDATA)
* Config file:
  * $PGDATA/postgresql.conf
  * $PGDATA/pg_hba.conf
* Daemon runs as `postgres` (`USER` directive)
* Startup log at /var/lib/pgsql/pgstartup.log
* Log directory: $PGDATA/pg_log
* pg_hba.conf allows to log in from addresses 0.0.0.0 and ::/0 using md5
* Environment variables:
  * POSTGRESQL_USER
  * POSTGRESQL_PASSWORD
  * POSTGRESQL_DATABASE
  * POSTGRESQL_ADMIN_PASSWORD
  * either root_password or user+password+database must be set if running with empty datadir, both combination is also valid
  * POSTGRESQL_DISABLE_CREATE_DB -- when set, it disables initializing DB and no other variables from the set above is required


### mongodb dockerfile:

* Binaries that must be available in the shell: mongo, mongod, mongos (installed packages: <collection>, <collection>-mongodb)
* Available commands within container:
  * `run-mongod` (default CMD)
  * `run-mongos`
* Exposed port: 27017,28017 (http://docs.mongodb.org/v2.6/reference/default-mongodb-port/)
* Directory for data (VOLUME): /var/lib/mongodb/data
* Config files: /etc/mongod.conf, /etc/mongoc.conf
* Daemon runs as `mongodb` (USER directive)
* Log file directory: /var/log/mongodb/
* Environment variables:
  * MONGODB_USER
  * MONGODB_PASSWORD
  * MONGODB_DATABASE
  * MONGODB_ADMIN_PASSWORD
  * either root_password or user+password+database must be set if running with empty datadir, both combination is also valid
  * MONGODB_DISABLE_CREATE_DB -- when set, it disables initializing DB and no other variables from the set above is required



