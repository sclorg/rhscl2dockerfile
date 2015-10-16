FROM centos:centos6

MAINTAINER SoftwareCollections.org <sclorg@redhat.com>

RUN yum -y --setopt=tsflags=nodocs install https://www.softwarecollections.org/en/scls/rhscl/{{ collection }}/epel-6-x86_64/download/rhscl-{{ collection }}-epel-6-x86_64.noarch.rpm && \
    yum clean all

RUN yum install -y --setopt=tsflags=nodocs {{ install|replace('@devel_libs', devel_libs) }} && yum clean all

{% include 'Dockerfile.content.template' %}
