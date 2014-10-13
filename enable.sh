#!/bin/bash
source /opt/rh/{{collection}}/enable
export X_SCLS="`scl enable {{collection}} 'echo $X_SCLS'`"
