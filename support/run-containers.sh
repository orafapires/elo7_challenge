#!/bin/bash

# Mongo
mongo(){
    docker run -d \
    --name "$MONGO" \
    --restart always \
    -v db_data:/data/db "$MONGO"
}

# API
api(){
    docker run -d \
    --name "$API" \
    -p 5000:5000 \
    --restart always \
    --link "$MONGO" "$API"
}

# Run Containers
run-containers(){
    case "$1" in
    "$MONGO") mongo ;;
    "$API") api ;;
    esac
}