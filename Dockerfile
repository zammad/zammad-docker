FROM ruby:2.3.1
MAINTAINER Zammad.org <info@zammad.org>
ARG BUILD_DATE

ENV ZAMMAD_DIR /opt/zammad
ENV ZAMMAD_DB zammad
ENV ZAMMAD_DB_USER zammad
ENV RAILS_ENV production
ENV RAILS_SERVER puma
ENV GIT_URL https://github.com/zammad/zammad.git
ENV GIT_BRANCH develop
ENV ES_SKIP_SET_KERNEL_PARAMETERS true

LABEL org.label-schema.build-date="$BUILD_DATE" \
      org.label-schema.name="Zammad" \
      org.label-schema.license="AGPL-3.0" \
      org.label-schema.description="Zammad Docker container for easy testing" \
      org.label-schema.url="https://zammad.org" \
      org.label-schema.vcs-url="https://github.com/zammad/zammad" \
      org.label-schema.vcs-type="Git" \
      org.label-schema.vendor="Zammad" \
      org.label-schema.schema-version="1.2" \
      org.label-schema.docker.cmd="docker run -ti -p 80:80 zammad/zammad"

# Expose ports
EXPOSE 80

# fixing service start
RUN echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d

# install zammad
COPY scripts/install-zammad.sh /tmp
RUN chmod +x /tmp/install-zammad.sh;/bin/bash -l -c /tmp/install-zammad.sh

# cleanup
RUN rm -rf /var/lib/apt/lists/* preseed.txt

# docker init
COPY scripts/docker-entrypoint.sh /
RUN chown zammad:zammad /docker-entrypoint.sh;chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["zammad"]
