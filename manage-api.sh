#!/bin/bash

# Set pwd variable
export PWD=$(pwd)

# Loading support scripts
source "$PWD"/support.sh || {
    echo "Este arquivo é o mínimo que precisamos para executar a API :)"
    return 1
}

# Loading support scripts
load_support_scripts(){
    source "$PWD"/support/colors.sh
    source "$PWD"/support/run-containers.sh
}

# Containers
MONGO=$(grep -i "mongo" "$PWD"/support/containers.txt)
API=$(grep -i "elo7_challenge" "$PWD"/support/containers.txt)
containers=( "$MONGO" "$API" )

# Base URL
prepare_url(){
    if [ -f "$PWD/support/server.txt" ]; then
        BASE_URL=$(cat "$PWD/support/server.txt")
        color g "URL base da API: $BASE_URL"
    else
        BASE_URL="$BASE_URL"
        color g "URL base da API: $BASE_URL"
    fi
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

# Start API with docker compose
start_api_with_compose(){
    docker-compose up -d --build
    health_check_api "$BASE_URL"
}

# Stop API with docker compose
stop_api_with_compose(){
    docker-compose down
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

# Getting git infos to post in API
get_git_infos(){
    COMPONENT=$(git config --get remote.origin.url)
    COMPONENT=$(echo "${COMPONENT//.git}" | cut -d'/' -f5)
    AUTHOR=$(git log -1 --pretty=format:'%an')
}

# Start script
verify_dep_files
check_dep_installed
load_support_scripts
prepare_url