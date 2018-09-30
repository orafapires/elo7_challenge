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
        echo "O diretório do projeto já existe. Deseja excluí-lo? [s/N]"
        read -r response
            case "$response" in
            [Ss][Ii][Mm]|[Ss]) rm -rf "$PROJECT" ;;
            [Nn][Ãã][Oo]|[Nn]) return 0 ;;
            *) echo "Resposta inválida" && check_dir ;;
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
    stop_api_with_compose
    start_api_with_compose
}

main
start_api