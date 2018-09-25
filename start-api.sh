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

get_state_running(){
    STATE=`docker inspect --format {{.State.Running}} "$1"`
    if [ "$STATE" == "true" ]; then
        echo "$1 está em execução"
    else
        echo "$1 não está em execução"
        exit 1
    fi
}

execute_api_without_compose(){
    MONGO="mongo"
    API="elo7-challenge"
    docker run -d --name $MONGO --restart always -v db_data:/data/db $MONGO && get_state_running $MONGO
    docker run -d --name $API -p 5000:5000 --restart always --link $MONGO $API && get_state_running $API
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



