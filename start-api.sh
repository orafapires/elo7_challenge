#!/bin/bash

# Dependencies
DOCKER="docker"
COMPOSE="docker-compose"
array=( "$DOCKER" "$COMPOSE" )

# Base URL
BASE_URL="http://localhost:5000"

command_exists(){
    type "$1"
}

execute_api_with_compose(){
    docker-compose up -d
}

execute_api_without_compose(){
    echo "Instale o $COMPOSE"
}

health_check_api(){
    while [ "$RESPONSE" != 200 ]; do
        RESPONSE=`curl -s -o /dev/null -w "%{http_code}" $BASE_URL`
        if [ "$RESPONSE" -eq 200 ]; then
            echo "API em funcionamento"
        else
            echo "API não está em funcionamento"
        fi
    done
}

for element in "${array[@]}"; do
    if [ "$element" == "$DOCKER" ]; then
        command_exists $element
        if [ "$?" -eq 1 ]; then
            echo "O $element é o mínimo que precisamos... bora instalar?"
            exit 1
        fi
    fi
    if [ "$element" == "$COMPOSE" ]; then
        command_exists $element
        if [ "$?" -eq 1 ]; then
            echo "O $element não é obrigatório, mas é recomendável :)"
            execute_api_without_compose
        else
            execute_api_with_compose
            health_check_api
        fi
    fi
done



