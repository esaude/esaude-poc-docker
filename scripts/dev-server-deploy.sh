#!/bin/bash
set -x

# Notify that deploy has started
SLACK_MESSAGE="eSaude EMR POC deploy initiated on `hostname`"
curl -X POST --data-urlencode 'payload={"username": "eSaude Infrastructure", "text": "'"$SLACK_MESSAGE"'", "icon_url": "https://apps.esaude.org/img/esaude-icon.png"}' $SLACK_WEBHOOK_URL

# Update docker repo to latest
cd /opt/esaude-poc-docker
git fetch origin
git clean -f -d
git reset --hard origin/master

# Force remote all containers and images
docker rm -v -f $(docker ps -a -q)
docker rmi -f $(docker images -q)

# Remove orphaned volumes
docker volume rm $(docker volume ls -qf dangling=true)

# If the POC_VERSION variable is set, deploy a tagged release
if [ -z "$POC_VERSION" ];
then
  # Fetch, build from master & run containers
  docker-compose up -d
else
  # Generate Docker Compose override file
  echo -e "version: '2'\n\
services:\n\
  esaude-emr-poc:\n\
    image: esaude-docker-poc-docker.bintray.io/poc:$POC_VERSION\n\
" >  docker-compose.override.yml

  # Start containers using released images
  docker-compose -f docker-compose.yml -f docker-compose.override.yml pull
  docker-compose -f docker-compose.yml -f docker-compose.override.yml up -d
fi

# Notify that containers have started
SLACK_MESSAGE="eSaude EMR POC containers started on `hostname`"
curl -X POST --data-urlencode 'payload={"username": "eSaude Infrastructure", "text": "'"$SLACK_MESSAGE"'", "icon_url": "https://apps.esaude.org/img/esaude-icon.png"}' $SLACK_WEBHOOK_URL
