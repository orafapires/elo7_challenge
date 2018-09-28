#!/bin/bash

# Listing dependencies
list=$(cut -d'=' -f1 < ../requirements.txt)

# Checking if mandatory dependencies have installed
for i in $list; do
    pip show "$i" &> /dev/null;
    if [ "$?" -eq 1 ]; then
        echo "$i não encontrada"
        exit 1
    else
        echo "$i encontrada"
    fi
done