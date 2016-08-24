#!/bin/bash
set -o xtrace

if [ -z "$POC_VERSION" ];
then
  # build from master
  docker build -t esaude-emr-poc .
else
  # build from tag
  docker build -t esaude-emr-poc --build-arg POC_VERSION="$POC_VERSION" .
fi
