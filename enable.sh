#!/bin/bash
{% for c in enable %}source /opt/rh/{{c}}/enable
{% endfor -%}
export X_SCLS="`scl enable {{ " ".join(enable) }} 'echo $X_SCLS'`"
