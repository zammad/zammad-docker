#!/bin/bash

DOCKER_LOGIN="$1"
DOCKER_PASS="$2"
DOCKER_REPO="$3"
PACKAGER_REPO="$4"

if [ -z $1 ] || [ -z $2 ] || [ -z $3 ] || [ -z $4 ] ; then
    echo "DockerHub login, pass & repo and/or packager.io repo missing!"
    echo "Please add as vars to build command!
    echo "example:              $0 dockerhub_login dockerhub_password dockerhub_repo packager.io_repo"
    echo "example for Zammad:   $0 zammad password zammad develop"
    echo "packager.io repo can be "stable, develop, stable-1.1 or anything else available @ https://packager.io/gh/zammad/zammad"
    exit 1
fi

docker build --no-cache --pull --build-arg PACKAGER_REPO=${PACKAGER_REPO} -t ${DOCKER_LOGIN}/${DOCKER_REPO}:${PACKAGER_REPO} .
docker login -u ${DOCKER_LOGIN} -p ${DOCKER_PASS}
docker push ${DOCKER_LOGIN}/${DOCKER_REPO}:${PACKAGER_REPO}
