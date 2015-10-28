boot2docker upgrade

boot2docker up

eval "$(boot2docker shellinit)"

docker build -t zammad .


docker images
docker ps --all

docker run -ti zammad /bin/bash

docker run --privileged -ti -v /sys/fs/cgroup:/sys/fs/cgroup:ro zammad /bin/bash






boot2docker down