boot2docker upgrade

boot2docker up

eval "$(boot2docker shellinit)"

docker build -t zammad .


docker images
docker ps --all

docker run -ti -p 80:80 zammad



boot2docker down


boot2docker ip
docker inspect *CONTAINERID*
