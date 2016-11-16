# Zammad ticketing system docker image for ubuntu
FROM ubuntu:16.04
MAINTAINER André Bauer <monotek23@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d

RUN apt-get update

RUN apt-get --no-install-recommends -y install apt-transport-https mc libterm-readline-perl-perl sudo wget openjdk-8-jre locales

RUN locale-gen en_US.UTF-8
RUN locale -a
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:UTF-8
ENV LC_ALL en_US.UTF-8
RUN echo "LANG=en_US.UTF-8" > /etc/default/locale

RUN echo "postfix postfix/main_mailer_type string Internet site" > preseed.txt
RUN debconf-set-selections preseed.txt
RUN apt-get --no-install-recommends install -q -y postfix

RUN wget -qO - https://deb.packager.io/key | sudo apt-key add -
RUN wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
RUN echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-5.x.list
RUN echo "deb https://deb.packager.io/gh/zammad/zammad xenial develop" | sudo tee /etc/apt/sources.list.d/zammad.list

RUN apt-get update
RUN apt-get --no-install-recommends -y install elasticsearch zammad

# Expose ports.
EXPOSE 80
EXPOSE 3000
EXPOSE 6042
EXPOSE 9200

# copy required scripts
ADD scripts/run.sh /tmp/run.sh
ADD scripts/setup.sh /tmp/setup.sh

# install packages etc
ADD scripts/docker.sh /tmp/docker.sh

RUN chmod +x /tmp/docker.sh
RUN /bin/bash -l -c /tmp/docker.sh

WORKDIR "/opt/zammad"

CMD ["/bin/bash", "/run.sh"]
