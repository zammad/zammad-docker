# Zammad ticketing system docker image
FROM centos:6
MAINTAINER Thorsten Eckel <thorsten.eckel@znuny.com>

# Expose ports.
EXPOSE 80
EXPOSE 3000
EXPOSE 6042
EXPOSE 9200

RUN rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch
RUN rpm --import https://rpm.packager.io/key

ADD elasticsearch.repo /etc/yum.repos.d/elasticsearch.repo
ADD zammad.repo /etc/yum.repos.d/zammad.repo
ADD nginx.repo /etc/yum.repos.d/nginx.repo

# TODO: Install dependencies - should get removed as far as possible when RPM is complete
RUN yum -y install postgresql postgresql-devel postgresql-server postfix elasticsearch java cronie nginx which zammad

RUN su - zammad /bin/bash -l -c "cd /opt/zammad && cp config/database.yml.dist config/database.yml"

RUN su - zammad /bin/bash -l -c "cd /opt/zammad && echo 'production:' > config/database.yml"
RUN su - zammad /bin/bash -l -c "cd /opt/zammad && echo '  adapter: postgresql' >> config/database.yml"
RUN su - zammad /bin/bash -l -c "cd /opt/zammad && echo '  database: zammad' >> config/database.yml"
RUN su - zammad /bin/bash -l -c "cd /opt/zammad && echo '  pool: 50' >> config/database.yml"
RUN su - zammad /bin/bash -l -c "cd /opt/zammad && echo '  timeout: 5000' >> config/database.yml"
RUN su - zammad /bin/bash -l -c "cd /opt/zammad && echo '  username: zammad' >> config/database.yml"
RUN su - zammad /bin/bash -l -c "cd /opt/zammad && echo '  password:' >> config/database.yml"

# setup DB
RUN /bin/bash -l -c "service postgresql initdb"
RUN /bin/bash -l -c "echo 'max_connections = 200' >> /var/lib/pgsql/data/postgresql.conf"
RUN /bin/bash -l -c "echo 'shared_buffers = 2GB' >> /var/lib/pgsql/data/postgresql.conf"
RUN /bin/bash -l -c "echo 'temp_buffers = 1GB' >> /var/lib/pgsql/data/postgresql.conf"
RUN /bin/bash -l -c "echo 'work_mem = 6MB' >> /var/lib/pgsql/data/postgresql.conf"
RUN /bin/bash -l -c "echo 'max_stack_depth = 2MB' >> /var/lib/pgsql/data/postgresql.conf"
RUN /bin/bash -l -c "service postgresql start && su - postgres -c 'createuser -s zammad'"

# TMP FIX
RUN /bin/bash -l -c "usermod -d /opt/zammad zammad"
RUN /bin/bash -l -c "service postgresql start && su - zammad && export RAILS_ENV=production && cd /opt/zammad && export PATH=/opt/zammad/bin:$PATH && export GEM_PATH=/opt/zammad/vendor/bundle/ruby/2.2.0/ && rake db:create && rake db:migrate && rake db:seed"

# TMP FIX set up nginx (should be own package)
RUN /bin/bash -l -c "rm -rf /etc/nginx/conf.d/*"
RUN su - zammad /bin/bash -l -c "sed -i.bak '/server_name\syour\.domain\.org;/d' /opt/zammad/contrib/nginx/sites-enabled/zammad.conf"
RUN /bin/bash -l -c "cp /opt/zammad/contrib/nginx/sites-enabled/zammad.conf /etc/nginx/conf.d/"


RUN /bin/bash -l -c "cd /usr/share/elasticsearch && bin/plugin -install elasticsearch/elasticsearch-mapper-attachments/2.5.0"
RUN /bin/bash -l -c "service postgresql start && service elasticsearch start && su - zammad && export RAILS_ENV=production && cd /opt/zammad && export PATH=/opt/zammad/bin:$PATH && export GEM_PATH=/opt/zammad/vendor/bundle/ruby/2.2.0/ && rails r \"Setting.set('es_url', 'http://localhost:9200')\" && sleep 15 && rake searchindex:rebuild"

ADD run.sh /run.sh
RUN chmod +x /run.sh

WORKDIR "/opt/zammad"

CMD ["/bin/bash", "/run.sh"]
