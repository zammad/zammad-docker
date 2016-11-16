# Zammad ticketing system docker image for ubuntu
FROM ubuntu:16.04
MAINTAINER André Bauer <monotek23@gmail.com>
ENV DEBIAN_FRONTEND noninteractive

# fixing service start
RUN echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d

# updating package list
RUN apt-get update

# install dependencies
RUN apt-get --no-install-recommends -y install apt-transport-https mc libterm-readline-perl-perl sudo wget openjdk-8-jre locales

# setting locale for postgresql
RUN locale-gen en_US.UTF-8
RUN locale -a
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:UTF-8
ENV LC_ALL en_US.UTF-8
RUN echo "LANG=en_US.UTF-8" > /etc/default/locale

# install postfix
RUN echo "postfix postfix/main_mailer_type string Internet site" > preseed.txt
RUN debconf-set-selections preseed.txt
RUN apt-get --no-install-recommends install -q -y postfix

# configure repos & keys
RUN wget -qO - https://deb.packager.io/key | sudo apt-key add -
RUN wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
RUN echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-5.x.list
RUN echo "deb https://deb.packager.io/gh/zammad/zammad xenial develop" | sudo tee /etc/apt/sources.list.d/zammad.list

# updating package list
RUN apt-get update

# install elasticsearch & attachment plugin
RUN apt-get --no-install-recommends -y install elasticsearch
RUN cd /usr/share/elasticsearch && bin/elasticsearch-plugin install mapper-attachments

# install zammad
RUN apt-get --no-install-recommends -y install zammad

# Expose ports.
EXPOSE 80
EXPOSE 3000
EXPOSE 6042
EXPOSE 9200

# postgresql config
RUN echo 'max_connections = 200' >> /etc/postgresql/9.5/main/postgresql.conf
RUN echo 'shared_buffers = 2GB' >> /etc/postgresql/9.5/main/postgresql.conf
RUN echo 'temp_buffers = 1GB' >> /etc/postgresql/9.5/main/postgresql.conf
RUN echo 'work_mem = 6MB' >> /etc/postgresql/9.5/main/postgresql.conf
RUN echo 'max_stack_depth = 2MB' >> /etc/postgresql/9.5/main/postgresql.conf

# copy required scripts
ADD scripts/run.sh /run.sh
ADD scripts/setup.sh /tmp/setup.sh

# changeing script permissions
RUN chmod +x /tmp/setup.sh
RUN chown zammad /tmp/setup.sh
RUN /bin/bash -l -c "usermod -d /opt/zammad zammad"
# Elasticsearch not ready in docker.sh at execution of setup.sh - sleep 10 until elasticsearch is accepting network connections
RUN service postgresql start && service elasticsearch start && sleep 10 && su - zammad -c '/tmp/setup.sh'
RUN chmod +x /run.sh

# set workdir
WORKDIR "/opt/zammad"

# set container start script
CMD ["/bin/bash", "/run.sh"]
