# Zammad ticketing system docker image
FROM centos:6
MAINTAINER Thorsten Eckel <thorsten.eckel@znuny.com>

# Expose ports.
EXPOSE 80
EXPOSE 3000
EXPOSE 6042
EXPOSE 9200

# add repository contents into docker images
ADD repos/elasticsearch.repo /etc/yum.repos.d/elasticsearch.repo
ADD repos/zammad.repo /etc/yum.repos.d/zammad.repo
ADD repos/nginx.repo /etc/yum.repos.d/nginx.repo

# copy required scripts
ADD scripts/run.sh /run.sh
ADD scripts/setup.sh /tmp/setup.sh

# install packages etc
ADD scripts/docker.sh /tmp/docker.sh

RUN chmod +x /tmp/docker.sh
RUN /bin/bash -l -c /tmp/docker.sh

WORKDIR "/opt/zammad"

CMD ["/bin/bash", "/run.sh"]
