#!/bin/bash

# Check if git have instaled
main(){
command -v git >/dev/null 2>&1 || {
    echo "Git não instalado :("
    exit 1
  }
}

# Start API
start_api(){
    git clone --depth=1 https://github.com/orafapires/elo7_challenge.git
    cd ./elo7_challenge || {
        echo "Diretório do projeto não encontrado :("
        exit 1
    }
    source ./manage-api.sh
    start_api_with_compose
}

main
start_api