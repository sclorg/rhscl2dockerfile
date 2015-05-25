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
* Auto-sharding for cloud-level scalability (currently in early alpha)
* Commercial Support Available

A key goal of MongoDB is to bridge the gap between key/value stores (which are
fast and highly scalable) and traditional RDBMS systems (which are deep in
functionality).

Usage
-----

To pass arguments that are used for initializing the database (if it is not yet initialized), define them as environment variables

```
docker run -d  -e MONGODB_USER=user -e MONGODB_PASSWORD=pass -e MONGODB_DATABASE=db -e MONGODB_ADMIN_PASSWORD=adminpass -p 27017:27017 THIS_IMAGE
```

It is recommended to use run the container with mounted data directory everytime.
This example shows how to run the container with `/host/data` directory mounted
and so the database will store data into this directory on host:

```
docker run -d -e MONGODB_USER=user -e MONGODB_PASSWORD=pass -e MONGODB_DATABASE=db -e MONGODB_ADMIN_PASSWORD=adminpass -v /host/data:/var/lib/mongodb/data THIS_IMAGE
```

Without specifying any commands on the command line, the mongod daemon is run.

To run Bash in the built Docker image, run

```
docker run -t -i THIS_IMAGE /bin/bash
```

To connect to running container, run

```
docker exec -t -i mongodb_database bash
```

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

**Notice: When mouting directory from host into the container, ensure that the mounted
directory has the appropriate permissions and that the owner and group of the directory
matches the user UID or name which is running inside the container.**

