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

# Containers
MONGO=$(grep -i "mongo" containers.txt)
API=$(grep -i "elo7-challenge" containers.txt)
containers=( "$MONGO" "$API" )

# Base URL
prepare_url(){
    FILE="server.txt"
    if [ -f "$FILE" ]; then
        BASE_URL=$(cat "$FILE")
        color g "URL base da API: $BASE_URL"
    else
        BASE_URL="$BASE_URL"
        color g "URL base da API: $BASE_URL"
    fi
}

# Check if command exists
command_exists(){
    type "$1"
}

# Check mandatory dependencies
check_dependencies(){
    for dependency in "${dependencies[@]}"; do
        command_exists "$dependency"
        if [ "$?" -eq 1 ]; then
            color r "O $dependency é o mínimo que precisamos para executar a API :)"
        fi
    done
}

# Post data in API
post_to_api(){
    if [ -z "$1" ] && [ -z "$2" ] && [ -z "$3" ]; then
        color r "Parâmetros necessários para realizar um POST na API:"
        color g "Dados, URL base da API e o endpoint :)"
    else
        curl -X POST \
        -H "Content-Type: application/json" \
        -d "$1" \
        "$2"/"$3"
    fi
}

# Stop API with docker compose
stop_api_with_compose(){
    docker-compose down
}

# Start API with docker compose
start_api_with_compose(){
    docker-compose up -d
    health_check_api "$BASE_URL"
}

# Start API with docker compose in CI
start_api_with_compose_ci(){
    docker-compose -f docker-compose-ci.yml up -d
    health_check_api "$BASE_URL"
}

# Health check API
health_check_api(){
    if [ -z "$1" ]; then
        color r "Esta função necessita da URL base da API como parâmetro :)"
    else
        while true; do
            RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$1")
            if [ "$RESPONSE" -eq 200 ]; then
                color b "### API em funcionamento ###"
                break
            else
                color r "### API não está em funcionamento ###"
            fi
        done
    fi
}

# Get running container
get_running_container(){
    RUNNING=$(docker ps -a \
    --format '{{.Names}}' \
    --format '{{.Status}}' \
    --filter 'name='"$1"'' \
    --filter 'status=running')
    if [ -z "$RUNNING" ]; then
        color y "### $1 não está em execução ###"
        return 1
    else
        color g "### $1 está em execução ###"
    fi
}

# Get exited container
get_exited_container(){
    EXITED=$(docker ps -a \
    --format '{{.Names}}' \
    --format '{{.Status}}' \
    --filter 'name='"$1"'' \
    --filter 'status=exited')
    if [ -z "$EXITED" ]; then
        return 0
    else
        return 1
    fi
}

# Start API without compose
start_api_without_compose(){
    for container in "${containers[@]}"; do
        get_running_container "$container"
        if [ "$?" -eq 1 ]; then
            get_exited_container "$container"
            if [ "$?" -eq 1 ]; then
                remove_container "$container"
                run-containers "$container"
            else
                run-containers "$container"
            fi
        fi
    done
    health_check_api "$BASE_URL" 
}

# Remove container
remove_container(){
    if [ -z "$1" ]; then
        color r "É necessário informar o nome ou o ID do container :)"
    else
        CONTAINER="$1"
        color g "Removendo $CONTAINER"
        docker rm "$CONTAINER"
    fi
}

# Kill container
kill_container(){
    if [ -z "$1" ]; then
        color r "É necessário informar o nome ou o ID do container :)"
    else
        CONTAINER="$1"
        color g "Matando $CONTAINER"
        docker kill "$CONTAINER"
    fi
}

# Stop API without compose
stop_api_without_compose(){
    for container in "${containers[@]}"; do
        get_running_container "$container"
        if [ "$?" -eq 0 ]; then
            kill_container "$container"
            remove_container "$container"
        fi
    done
}

# Start script
check_dependencies
prepare_url