#!/bin/bash

git clone --depth=1 https://github.com/orafapires/elo7_challenge.git
cd ./elo7_challenge
source ./manage-api.sh
start_api_with_compose