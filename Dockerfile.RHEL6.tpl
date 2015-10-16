FROM rhel6

RUN yum install -y --setopt=tsflags=nodocs yum-utils && \
    yum-config-manager --enable rhel-server-rhscl-6-rpms && \
    yum-config-manager --enable rhel-6-server-optional-rpms && \
    yum clean all

RUN yum install -y --setopt=tsflags=nodocs {{ install|replace('@devel_libs', devel_libs) }} && yum clean all

{% include './Dockerfile.content.template' %}

