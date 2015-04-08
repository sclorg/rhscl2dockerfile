#!/bin/bash
{% if enable %}
source scl_source enable{% for c in enable %} {{c}}{% endfor -%}
{% endif %}
