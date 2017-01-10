# Zammad ticketing system docker image for Ubuntu 16.04
FROM ubuntu:16.04
MAINTAINER Zammad.org <info@zammad.org>
ARG PACKAGER_REPO
ARG BUILD_DATE
WORKDIR "/opt/zammad"

LABEL org.label-schema.build-date="$BUILD_DATE" \
      org.label-schema.name="Zammad" \
      org.label-schema.license="AGPL-3.0" \
      org.label-schema.description="Docker container for Zammad" \
      org.label-schema.url="https://zammad.org" \
      org.label-schema.vcs-url="https://github.com/zammad/zammad" \
      org.label-schema.vcs-type="Git" \
      org.label-schema.vendor="Zammad" \
      org.label-schema.schema-version="1.2" \
      org.label-schema.docker.cmd="docker run -ti -p 80:80 zammad/zammad:develop"

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
