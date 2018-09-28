#!/bin/bash

# Project name
PROJECT="elo7_challenge"

# Check if git have instaled
main(){
command -v git >/dev/null 2>&1 || {
    echo "Git não instalado :("
    exit 1
  }
}

# Check if directory project exists
check_dir(){
    if [ -d "$PROJECT" ]; then
        echo "O diretório do projeto já existe. Deseja excluí-lo?"
        read -r response
            case "$response" in
            "sim") rm -rf "$PROJECT" ;;
            "não") return 0 ;;
            *) echo "Resposta inválida" && return 1 ;;
            esac
    else
        return 0
    fi
}

# Start API
start_api(){
    check_dir
    git clone --depth=1 https://github.com/orafapires/"$PROJECT".git
    cd ./"$PROJECT" || {
        echo "Diretório do projeto não encontrado :("
        exit 1
    }
    source ./manage-api.sh
    start_api_with_compose
}

main
start_api
check_dir