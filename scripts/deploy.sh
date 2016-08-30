#!/bin/bash
set -o xtrace

# Log in to the Bintray Docker registry
docker login -u $BINTRAY_USER -p $BINTRAY_API_KEY -e $BINTRAY_EMAIL esaude-docker-poc-docker.bintray.io

# Tag the image
docker tag `docker images -q esaude-emr-poc` esaude-docker-poc-docker.bintray.io/poc:$POC_VERSION

# Push the image
docker push esaude-docker-poc-docker.bintray.io/poc:$POC_VERSION

# Notify to slack
SLACK_MESSAGE="New eSaude POC Docker image ($POC_VERSION) published <https://bintray.com/esaude/poc-docker/poc|here>"
curl -X POST --data-urlencode 'payload={"username": "eSaude Bintray", "text": "'"$SLACK_MESSAGE"'", "icon_url": "https://bintray.com/assets/favicon.png"}' $SLACK_WEBHOOK_URL
