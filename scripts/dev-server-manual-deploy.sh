#!/bin/bash
set -x

# Notify that deploy has started
SLACK_MESSAGE="eSaude EMR POC deploy initiated on `hostname`"
curl -X POST --data-urlencode 'payload={"username": "eSaude Infrastructure", "text": "'"$SLACK_MESSAGE"'", "icon_url": "https://apps.esaude.org/img/esaude-icon.png"}' $

# Update docker repo to latest
cd /opt/manual-deploy/esaude-poc-docker
git fetch origin
git clean -f -d
git reset --hard origin/master

# Update esaude-emr-poc repo to latest
cd /opt/manual-deploy/esaude-emr-poc
git fetch origin
git clean -f -d
git reset --hard origin/master

#Install the Node.js and Bower dependencies
npm install
bower install

#Build the distributable package from source. This will create an archive called esaude-emr-poc-master.zip, which can be deployed on a web server.
grunt build:package

#Remove the old archive esaude-emr-poc.zip
cd /opt/manual-deploy/esaude-poc-docker
rm esaude-emr-poc.zip
echo "esaude-emr-poc.zip was removed" 

#Update the repo esaude-poc-docker with the latest esaude-emr-poc.zip archive
cp /opt/manual-deploy/esaude-emr-poc/esaude-emr-poc.zip /opt/manual-deploy/esaude-poc-docker/esaude-emr-poc.zip

#Update the Dockerfile and docker-compose.yml of the docker repo. It should look for the esaude-emr-poc.zip locally instead of Bintray 
cp /opt/manual-deploy/Dockerfile-poc-docker /opt/manual-deploy/esaude-poc-docker/Dockerfile
cp /opt/manual-deploy/docker-compose-poc-docker.yml /opt/manual-deploy/esaude-poc-docker/docker-compose.yml

# Force remove all containers and images
#docker rm -f $(docker ps -a -q)
#docker rmi -f $(docker images -q)
docker rm -f esaude-emr-poc
docker rmi -f $(docker images -q) 

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
curl -X POST --data-urlencode 'payload={"username": "eSaude Infrastructure", "text": "'"$SLACK_MESSAGE"'", "icon_url": "https://apps.esaude.org/img/esaude-icon.png"}' $

