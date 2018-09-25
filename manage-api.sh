#!/bin/bash

# Load colors to terminal
source colors.sh

# Load functions to run containers
source run-containers.sh

# Dependencies
DOCKER="docker"
COMPOSE="docker-compose"
CURL="curl"
dependencies=( "$DOCKER" "$COMPOSE" "$CURL" )

# Base URL
BASE_URL="http://localhost:5000"
DATA='{"component" : "teste", "version" : "2.0", "accountable" : "eu", "status" : "teste"}'

# Containers
MONGO="mongo"
API="elo7-challenge"

command_exists(){
    type "$1"
}

error_cmd_not_exists(){
    if [ "$?" -eq 1 ]; then
        color r "O $element é o mínimo que precisamos para executar a API :)?"
    fi
}

check_dependencies(){
    for element in "${dependencies[@]}"; do
        command_exists "$element"
        error_cmd_not_exists
    done
}

post_to_api(){
    export ENDPOINT="deploy-time"
    curl -X POST \
    -H "Content-Type: application/json" \
    -d "$DATA" \
    "$BASE_URL"/"$ENDPOINT"
}

stop_api_with_compose(){
    docker-compose down
}

start_api_with_compose(){
    docker-compose up -d
}

health_check_api(){
    while [ "$RESPONSE" != 200 ]; do
        RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL)
        if [ "$RESPONSE" -eq 200 ]; then
            color b "API em funcionamento"
        else
            color r "API não está em funcionamento"
        fi
    done
}

get_state_running(){
    PS=$(docker ps --format '{{.Names}}' --filter 'name='"$1"'')
    if [ -z "$PS" ]; then
            color y "$1 não está em execução"
            return 1
        else
            color g "$1 está em execução"
    fi
}

start_api_without_compose(){
    get_state_running $MONGO
        if [ "$?" -eq 1 ]; then
            mongo "$MONGO"
        fi
    get_state_running $API
        if [ "$?" -eq 1 ]; then
            api "$API"
        fi
}

remove_container(){
    CONTAINER="$1"
    color b "Removendo $CONTAINER"
    docker kill "$CONTAINER" &> /dev/null;
    docker rm "$CONTAINER" &> /dev/null;
    color g "$CONTAINER removido"
}

stop_api_without_compose(){
    get_state_running $MONGO
    remove_container $MONGO
    get_state_running $API
    remove_container $API
}

check_dependencies