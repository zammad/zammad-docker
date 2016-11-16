#!/bin/bash

set -ex

docker build --no-cache --pull -t monotek/zammad:latest .
docker login -u zammad -p ${DOCKERHUB_PW}
docker push zammad/zammad:latest
