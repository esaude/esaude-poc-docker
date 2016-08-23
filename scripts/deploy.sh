#!/bin/bash
set -o xtrace

# Log in to the Bintray Docker registry
docker login -u $BINTRAY_USER -p $BINTRAY_API_KEY -e $BINTRAY_EMAIL esaude-docker-poc-docker.bintray.io

# Tag the image
docker tag `docker images -q esaude-emr-poc` esaude-docker-poc-docker.bintray.io/poc:$POC_VERSION

# Push the image
docker push esaude-docker-poc-docker.bintray.io/poc:$POC_VERSION
