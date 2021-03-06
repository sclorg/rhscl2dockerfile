{{ name }} Docker Image based on {{ collection }} Software Collection
{{ '=' * (collection|length + 43 + name|length) }}

Mongo (from "humongous") is a high-performance, open source, schema-free
document-oriented database. MongoDB is written in C++ and offers the following
features:
* Collection oriented storage: easy storage of object/JSON-style data
* Dynamic queries
* Full index support, including on inner objects and embedded arrays
* Query profiling
* Replication and fail-over support
* Efficient storage of binary data including large objects (e.g. photos
  and videos)
* Auto-sharding for cloud-level scalability

A key goal of MongoDB is to bridge the gap between key/value stores (which are
fast and highly scalable) and traditional RDBMS systems (which are deep in
functionality).

The Docker image includes packages from Software Collections (SCL). For more
information about Software Collections, see http://softwarecollections.org.



Usage
-----

To just run the daemon and not store the database in a host directory,
you need to execute the following command:

```
docker run -d -e MONGODB_USER=user -e MONGODB_PASSWORD=pass -e MONGODB_DATABASE=db -e MONGODB_ADMIN_PASSWORD=adminpass -p 27017:27017 THIS_IMAGE
```

This will run the mongod daemon in default configuration and port 27017 will be
exposed and mapped to host.

It is recommended to run the container with mounted data directory every time.
This example shows how to run the container with `/host/data` directory mounted
and so the database will store data into this directory on host:

```
docker run -d -e MONGODB_USER=user -e MONGODB_PASSWORD=pass -e MONGODB_DATABASE=db -e MONGODB_ADMIN_PASSWORD=adminpass -v /host/data:/var/lib/mongodb/data -p 27017:27017 THIS_IMAGE
```

This will create a container running mongod daemon and storing data
into `/host/data` on the host.

For debugging purposes or just connecting to the running container, run
`docker exec -ti CONTAINERID container-entrypoint` in a separate terminal.

You can stop the detached container by running `docker stop CONTAINERID`.



Database initialization
-----------------------

If the database directory is not initialized, the container script will create database users. If you mount already initialized database, script will skip this task. However you still have to specify '_USER+_PASSWORD+_DATABASE+_ADMIN_PASSWORD' environment variables to be able to connect to database from linked container.

To pass arguments that are used for database initializing define them as environment variables (see table below).

```
docker run -d -e MONGODB_USER=user -e MONGODB_PASSWORD=pass -e MONGODB_DATABASE=db -e MONGODB_ADMIN_PASSWORD=adminpass -v /host/data:/var/lib/mongodb/data -p 27017:27017 --name database THIS_IMAGE
```

This will create a container running {{ name }} with database
`db` and user with credentials `user:pass` that has access to the database `db`.

You can connect to the database by `docker run --link database:db -ti THIS_IMAGE bash -c 'mongo $DB_ENV_MONGODB_DATABASE -u $DB_ENV_MONGODB_USER -p $DB_ENV_MONGODB_PASSWORD --host $DB_PORT_27017_TCP_ADDR:27017'`.

Users created by container script have these user roles:
- admin user - `roles: ['dbAdminAnyDatabase', 'userAdminAnyDatabase' , 'readWriteAnyDatabase','clusterAdmin' ]`
- MONGODB_USER - `roles: [ 'readWrite' ]` in database: `$MONGODB_DATABASE`

Environment variables and volumes
---------------------------------

The image recognizes following environment variables that you can set during
initialization, by passing `-e VAR=VALUE` to the Docker run command.

|    Variable name          |    Description                              |
| :------------------------ | ------------------------------------------- |
|  `MONGODB_USER`           | User name for MongoDB account to be created |
|  `MONGODB_PASSWORD`       | Password for the user account               |
|  `MONGODB_DATABASE`       | Database name in which to create user       |
|  `MONGODB_ADMIN_PASSWORD` | Password for the admin user                 |

Following environment variables influence MongoDB configuration file. They are all optional.

|    Variable name      |    Description                                                            |  Default  |
| :-------------------- | ------------------------------------------------------------------------- | --------- |
|  `MONGODB_NOPREALLOC` | Disable data file preallocation.                                          |  true     |
|  `MONGODB_SMALLFILES` | Set MongoDB to use a smaller default data file size.                      |  true     |
|  `MONGODB_QUIET`      | Runs MongoDB in a quiet mode that attempts to limit the amount of output. |  true     |

You can also set following mount points by passing `-v /host:/container` flag to docker.

|  Volume mount point      | Description            |
| :----------------------- | ---------------------- |
|  `/var/lib/mongodb/data` | MongoDB data directory |

**Notice: When mounting directory from host into the container, ensure that the mounted
directory has the appropriate permissions and that the owner and group of the directory
matches the user UID or name which is running inside the container.**



Configuration
-------------

To configure the image you can mount MongoDB configuration file into container. For example to mount config file `/host/mongod.conf` into container add this option `-e /host/mongod.conf:/etc/mongod.conf` to `docker run` command.

It is also possible to mount shell scripts and these scripts will be run during the container start.
(Note that only '*.sh' files from directories described below will be automatically sourced.)

You can mount scripts into these directories:
- `/usr/share/cont-volume/mongodb/pre-init.d` - scripts from this directory will be sourced right before MongoDB daemon start on localhost.
- `/usr/share/cont-volume/mongodb/init.d` - scripts from this directory will be sourced when MongoDB daemon is started on localhost (without authentication).
- `/usr/share/cont-volume/mongodb/post-init.d` - scripts from this directory will be sourced right before MongoDB daemon is started.

This image follow the 'cont-lib' [2] directory hierarchy. So you can fill similar directories under `/usr/share/cont-layer` by layers above the actual image.

[2] https://github.com/devexp-db/cont-lib/tree/master/share
