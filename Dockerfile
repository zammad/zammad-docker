# Zammad ticketing system docker image for ubuntu
FROM ubuntu:16.04
MAINTAINER André Bauer <monotek23@gmail.com>

# Expose ports.
EXPOSE 80
EXPOSE 3000
EXPOSE 6042
EXPOSE 9200

# copy required scripts
ADD scripts/run.sh /run.sh
ADD scripts/setup.sh /tmp/setup.sh

# install packages etc
ADD scripts/docker.sh /tmp/docker.sh

RUN chmod +x /tmp/docker.sh
RUN /bin/bash -l -c /tmp/docker.sh

WORKDIR "/opt/zammad"

CMD ["/bin/bash", "/run.sh"]
