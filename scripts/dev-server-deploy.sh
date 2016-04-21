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

# Initialize database container (give it 90 seconds)
docker-compose up -d esaude-platform-mysql
set +x
for i in `seq 1 90`;
do
  percent=$(bc <<< "scale=4; $i/90*100")
  printf 'Waiting for mysql to initialize: %.2f%%\r' $percent
  sleep 1
done
set -x
docker-compose stop esaude-platform-mysql

# Start all containers
docker-compose up -d
