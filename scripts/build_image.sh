#!/bin/bash

set -ex

if [ "${TRAVIS}" == 'true' ]; then
  echo "Build Zammad Docker image with version ${ZAMMAD_VERSION} for DockerHubs ${DOCKER_REGISTRY}/${GITHUB_USERNAME}/${DOCKER_REPOSITORY} repo"

  docker build --pull --no-cache --build-arg BUILD_DATE=$(date -u +”%Y-%m-%dT%H:%M:%SZ”) -t ${DOCKER_REGISTRY}/${GITHUB_USERNAME}/${DOCKER_REPOSITORY}:latest -t ${DOCKER_REGISTRY}/${GITHUB_USERNAME}/${DOCKER_REPOSITORY}:${ZAMMAD_VERSION} .

  docker push ${DOCKER_REGISTRY}/${GITHUB_USERNAME}/${DOCKER_REPOSITORY}:latest

  docker push ${DOCKER_REGISTRY}/${GITHUB_USERNAME}/${DOCKER_REPOSITORY}:${ZAMMAD_VERSION}
else
  DOCKER_LOGIN="$1"
  DOCKER_PASS="$2"
  DOCKER_REPO="$3"

  if [ -z $1 ] || [ -z $2 ] || [ -z $3 ]  ; then
    echo "DockerHub login, pass and/or repo missing!"
    echo "Please add as vars to build command for local build!"
    echo "example:              $0 dockerhub_login dockerhub_password dockerhub_repo"
    echo "example for Zammad:   $0 zammad password zammad"
    exit 1
  fi

  echo "Build Zammad Docker image for DockerHubs ${DOCKER_REPO}:latest repo"

  docker image build --no-cache --pull --build-arg ${GIT_BRANCH} --build-arg BUILD_DATE=$(date -u +”%Y-%m-%dT%H:%M:%SZ”) -t ${DOCKER_LOGIN}/${DOCKER_REPO}:latest .
  docker login -u ${DOCKER_LOGIN} -p ${DOCKER_PASS}
  docker image push ${DOCKER_LOGIN}/${DOCKER_REPO}:latest

fi
