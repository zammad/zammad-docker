#!/bin/bash

DOCKER_LOGIN="$1"
DOCKER_PASS="$2"
DOCKER_REPO="$3"

if [ -z $1 ] || [ -z $2 ] || [ -z $3 ]  ; then
  echo "DockerHub login, pass and/or repo missing!"
  echo "Please add as vars to build command!"
  echo "example:              $0 dockerhub_login dockerhub_password dockerhub_repo"
  echo "example for Zammad:   $0 zammad password zammad"
  exit 1
fi

docker image build --no-cache --pull --build-arg ${GIT_BRANCH} --build-arg BUILD_DATE=$(date -u +”%Y-%m-%dT%H:%M:%SZ”) -t ${DOCKER_LOGIN}/${DOCKER_REPO}:latest .
docker login -u ${DOCKER_LOGIN} -p ${DOCKER_PASS}
docker image push ${DOCKER_LOGIN}/${DOCKER_REPO}:latest
