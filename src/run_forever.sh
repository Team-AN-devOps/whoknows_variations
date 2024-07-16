#!/bin/bash

PYTHON_SCRIPT_PATH=$1

TMP="This variable might become useful at some point." 

while true
do
    python $PYTHON_SCRIPT_PATH
    if [ $? -ne 0 ]; then
        echo "Script crashed with exit code $?. Restarting..." >&2
        sleep 1
    fi
done