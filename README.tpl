Software Collection {{ container }} Dockerfile
{{ '=' * (container|length + 31) }}

How to build this Dockerfile
----------------------------

Building this Dockerfile requires a Red Hat Enterprise Linux 7 host
system with Software Collections entitlements available.

To build the Dockerfile, run:

```
# cd {{ collection }}
# docker build -t={{ collection }} .
```

{% for f in readme %}
{% include f %}
{% endfor -%}

{% include 'common/cont-lib/usr/share/cont-docs/70-general.txt.tpl' %}

