#!/bin/bash

# Log in to the Bintray Docker registry
docker login -u $BINTRAY_USER -p $BINTRAY_API_KEY esaude-docker-poc-docker.bintray.io

set -o xtrace

# Tag the image
docker tag `docker images -q esaude-emr-poc` esaude-docker-poc-docker.bintray.io/poc:$POC_VERSION

# Push the image
docker push esaude-docker-poc-docker.bintray.io/poc:$POC_VERSION

# Bundle app for offline install
docker save -o esaude-app-poc.tar esaude-docker-poc-docker.bintray.io/poc
gzip esaude-app-poc.tar

# Notify to slack
if [ "$POC_VERSION" = "master" ];
then
  # build from master
  SLACK_MESSAGE="New eSaude POC <https://bintray.com/esaude/poc-docker/poc|Docker image> published ($POC_VERSION)"
else
  SLACK_MESSAGE="New eSaude POC <https://bintray.com/esaude/poc-docker/poc|Docker image> and <https://bintray.com/esaude/apps/esaude-app-poc|offline installer> published ($POC_VERSION)"
fi

curl -X POST --data-urlencode 'payload={"username": "eSaude Bintray", "text": "'"$SLACK_MESSAGE"'", "icon_url": "https://bintray.com/assets/favicon.png"}' $SLACK_WEBHOOK_URL
