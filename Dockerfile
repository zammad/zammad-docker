# Zammad ticketing system docker image for Ubuntu 16.04
FROM ubuntu:16.04
MAINTAINER Zammad.org <info@zammad.org>
ARG PACKAGER_REPO
ARG BUILD_DATE
WORKDIR "/opt/zammad"

ENV RAILS_ENV production

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

# fixing service start
RUN echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d

# install zammad
COPY scripts/install-zammad.sh /tmp
RUN chmod +x /tmp/install-zammad.sh;/bin/bash -l -c /tmp/install-zammad.sh

# cleanup
RUN rm -rf /var/lib/apt/lists/*

# docker init
COPY scripts/docker-entrypoint.sh /
RUN chown zammad:zammad /docker-entrypoint.sh;chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["zammad"]
