#!/bin/bash

DOCKER_LOGIN="$1"
DOCKER_PASS="$2"
DOCKER_REPO="$3"
GIT_BRANCH="$4"

if [ -z $1 ] || [ -z $2 ] || [ -z $3 ] || [ -z $4 ] ; then
    echo "DockerHub login, pass & repo and/or git branch missing!"
    echo "Please add as vars to build command!"
    echo "example:              $0 dockerhub_login dockerhub_password dockerhub_repo git_branch"
    echo "example for Zammad:   $0 zammad password zammad develop"
    echo "git_branch can be stable, develop, stable-1.1 or anything else available @ https://github.com/zammad/zammad"
    exit 1
fi

docker build --no-cache --pull --build-arg ${GIT_BRANCH} --build-arg BUILD_DATE=$(date -u +”%Y-%m-%dT%H:%M:%SZ”) -t ${DOCKER_LOGIN}/${DOCKER_REPO}:${GIT_BRANCH} .
docker login -u ${DOCKER_LOGIN} -p ${DOCKER_PASS}
docker push ${DOCKER_LOGIN}/${DOCKER_REPO}:${GIT_BRANCH}
