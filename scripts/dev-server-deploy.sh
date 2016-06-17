#!/bin/bash
set -x

# Update docker repo to latest
cd /opt/esaude-poc-docker
git fetch origin
git reset --hard origin/master

# Force remote all containers and images
docker rm -f $(docker ps -a -q)
docker rmi -f $(docker images -q)

# Fetch/build containers
docker-compose pull
docker-compose build

# Start all containers
docker-compose up -d
