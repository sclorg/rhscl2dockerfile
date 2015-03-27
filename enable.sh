#!/bin/bash
source /opt/rh/{{collection}}/enable
export X_SCLS="`scl enable {{enable}} 'echo $X_SCLS'`"
