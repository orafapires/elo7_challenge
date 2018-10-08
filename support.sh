#!/bin/bash

# Set pwd variable
export PWD=$(pwd)

# Check if command exists
command_exists(){
    type "$1"
}

# Check dependency files
check_dep_files(){
    FILE=$(find "$PWD"/support -name "$1" -type f)
        if [ -z "$1" ]; then
            echo "Esta função necessita do nome do arquivo da dependência :)"
        elif [ -z "$FILE" ]; then
            echo "$1 não encontrado :("
        else
            return 0
        fi
}

verify_dep_files(){
    expected=( "colors.sh" "dependencies.txt" "run-containers.sh" "containers.txt" )
    for file in "${expected[@]}"; do
        check_dependency_files "$file"
    done
}

# Check mandatory dependencies
check_dep_installed(){
    FILE="$PWD/support/dependencies.txt"
        for dependency in $(cat $FILE); do
            command_exists "$dependency"
            if [ "$?" -eq 1 ]; then
                color r "O $dependency é o mínimo que precisamos para executar a API :)"
                exit 1
            fi
        done
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

# Checking if mandatory dependencies have installed
check_deps_mandatory(){
    for dep in $(cut -d'=' -f1 < "$PWD"/requirements.txt); do
    pip show "$dep" &> /dev/null;
    if [ "$?" -eq 1 ]; then
        echo "$dep não encontrada"
        exit 1
    else
        echo "$dep encontrada"
    fi
    done
}