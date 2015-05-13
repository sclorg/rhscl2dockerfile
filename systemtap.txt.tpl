{{ container }} Docker Image based on {{ collection }} Software Collection
{{ '=' * (container|length + 43 + collection|length) }}

SystemTap is an instrumentation system for systems running Linux.
Developers can write instrumentation scripts to collect data on
the operation of the system.  The base systemtap package contains/requires
the components needed to locally develop and execute systemtap scripts.


Usage
-----

This container is expected to be run as privileged container:

```
docker run --privileged {{ container }}
```


