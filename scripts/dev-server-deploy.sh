#!/bin/bash
set -x

# Notify that deploy has started
SLACK_MESSAGE="eSaude EMR POC deploy initiated on `hostname`"
curl -X POST --data-urlencode 'payload={"username": "eSaude Infrastructure", "text": "'"$SLACK_MESSAGE"'", "icon_url": "https://apps.esaude.org/img/esaude-icon.png"}' $SLACK_WEBHOOK_URL

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

# Notify that deploy has started
SLACK_MESSAGE="eSaude EMR POC containers started on `hostname`"
curl -X POST --data-urlencode 'payload={"username": "eSaude Infrastructure", "text": "'"$SLACK_MESSAGE"'", "icon_url": "https://apps.esaude.org/img/esaude-icon.png"}' $SLACK_WEBHOOK_URL
