#!/bin/bash

# Mongo
mongo(){
    export MONGO="$1"
    docker run -d \
    --name "$MONGO" \
    --restart always \
    -v db_data:/data/db "$MONGO"
}

# API
api(){
    export API="$1"
    docker run -d \
    --name "$API" \
    -p 5000:5000 \
    --restart always \
    --link "$MONGO" "$API"
}