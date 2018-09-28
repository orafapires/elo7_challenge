#!/bin/bash

# Mongo
mongo(){
    docker run -d \
    --name "$MONGO" \
    --restart always \
    --volume db_data:/data/db "$MONGO"
}

# API
api(){
    docker run -d \
    --name "$API" \
    --restart always \
    -p 5000:5000 \
    --volume "$PWD":/usr/src/app \
    --link "$MONGO" "$API"
}

# Run Containers
run-containers(){
    case "$1" in
    "$MONGO") mongo ;;
    "$API") api ;;
    esac
}