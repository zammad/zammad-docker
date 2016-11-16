#!/bin/bash

set -ex

docker build --no-cache --pull -t monotek/zammad:latest .
docker login -u monotek -p e6rp0CTlKWQU2BVkfWmJ
docker push monotek/zammad:latest
