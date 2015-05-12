FROM rhel6

MAINTAINER docker@softwarecollections.org

RUN yum install -y yum-utils && \
    yum-config-manager --enable rhel-server-rhscl-6-rpms && \
    yum-config-manager --enable rhel-6-server-optional-rpms && \
    yum clean all

RUN yum install -y --setopt=tsflags=nodocs {{ install }} && yum clean all

{% include './Dockerfile.content.template' %}

