FROM centos:centos7

MAINTAINER docker@softwarecollections.org

RUN yum -y --setopt=tsflags=nodocs install https://www.softwarecollections.org/en/scls/rhscl/{{ collection }}/epel-7-x86_64/download/rhscl-{{ collection }}-epel-7-x86_64.noarch.rpm && \
    yum clean all

RUN yum install -y --setopt=tsflags=nodocs {{ install|replace('@devel_libs', devel_libs) }} && yum clean all

{% include 'Dockerfile.content.template' %}
