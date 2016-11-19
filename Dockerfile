# Zammad ticketing system docker image for Ubuntu 16.04
FROM ubuntu:16.04
MAINTAINER André Bauer <monotek23@gmail.com>
ENV DEBIAN_FRONTEND noninteractive
ARG PACKAGER_REPO=develop
WORKDIR "/opt/zammad"

# Expose ports
EXPOSE 80
EXPOSE 3000
EXPOSE 6042
EXPOSE 9200

# copy required scripts
ADD scripts/run.sh /run.sh
ADD scripts/setup.sh /tmp/setup.sh
ADD scripts/docker.sh /tmp/docker.sh

# fixing service start
RUN echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d

# install packages
RUN chmod +x /tmp/docker.sh
RUN PACKAGER_REPO="$PACKAGER_REPO" /bin/bash -l -c /tmp/docker.sh

# docker init
CMD ["/bin/bash", "/run.sh"]
