# Zammad ticketing system docker image
FROM centos:7
MAINTAINER Thorsten Eckel <thorsten.eckel@znuny.com>

ENV ZAMMAD_VERSION 1.0
ENV ZAMMAD_BUILD_VERSION 1

# TODO: Move to Jenkins
RUN rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch

ADD elasticsearch.repo /etc/yum.repos.d/elasticsearch.repo

# TODO: Install dependencies - should get removed as far as possible when RPM is complete
RUN yum -y install mariadb-devel mariadb-libs mariadb-server mariadb postfix elasticsearch java

# requirements
RUN yum -y install cronie httpd

RUN yum -y install http://repo.zammad.org/centos/7/noarch/zammad-repo-${ZAMMAD_VERSION}-${ZAMMAD_BUILD_VERSION}.noarch.rpm
RUN yum -y install zammad


# RUN systemctl enable mariadb.service
# /usr/lib/systemd/system/mariadb.service
RUN /usr/bin/mysqld_safe --basedir=/usr
# RUN /usr/libexec/mariadb-wait-ready $MAINPID


# RUN systemctl enable elasticsearch.service
# /usr/lib/systemd/system/elasticsearch.service
ENV ES_ES_HOME=/usr/share/elasticsearch
ENV ES_CONF_DIR=/etc/elasticsearch
ENV ES_CONF_FILE=/etc/elasticsearch/elasticsearch.yml
ENV ES_DATA_DIR=/var/lib/elasticsearch
ENV ES_LOG_DIR=/var/log/elasticsearch
ENV ES_PID_DIR=/var/run/elasticsearch

RUN su - zammad /usr/bin/bash -c "/usr/share/elasticsearch/bin/elasticsearch \
                                                -Des.pidfile=$ES_PID_DIR/elasticsearch.pid \
                                                -Des.default.path.home=$ES_ES_HOME \
                                                -Des.default.path.logs=$ES_LOG_DIR \
                                                -Des.default.path.data=$ES_DATA_DIR \
                                                -Des.default.config=$ES_CONF_FILE \
                                                -Des.default.path.conf=$ES_CONF_DIR"


# RUN systemctl enable postfix.service
# /usr/lib/systemd/system/postfix.service
RUN /usr/libexec/postfix/aliasesdb
RUN /usr/libexec/postfix/chroot-update
RUN /usr/sbin/postfix start




# TODO: Move to RPM?
RUN su - zammad /usr/bin/bash -c "cd zammad && cp config/database.yml.dist config/database.yml"
# RUN su - zammad /usr/bin/bash -c "cd zammad && export RAILS_ENV=production"
# RUN su - zammad /usr/bin/bash -c "cd zammad && rake db:create"
# RUN su - zammad /usr/bin/bash -c "cd zammad && rake db:migrate"
# RUN su - zammad /usr/bin/bash -c "cd zammad && rake db:seed"
# RUN su - zammad /usr/bin/bash -c "cd zammad && rake assets:precompile"
# RUN su - zammad /usr/bin/bash -c "cd zammad && script/websocket-server.rb start"
# RUN su - zammad /usr/bin/bash -c "cd zammad && script/scheduler.rb start"

# CMD ["su - zammad /usr/bin/bash -c 'cd zammad && puma -p 3000'"]

CMD ["/bin/bash"]