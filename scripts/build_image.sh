#!/bin/bash

set -ex

docker build --no-cache --pull -t zammad/zammad:latest .
docker login -u zammad -p ${DOCKERHUB_PW}
docker push zammad/zammad:latest
