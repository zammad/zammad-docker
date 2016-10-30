#! /bin/bash

rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch
rpm --import https://rpm.packager.io/key

# TODO: Install dependencies - should get removed as far as possible when RPM is complete
yum -y install epel-release
yum -y install https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-6-x86_64/pgdg-redhat96-9.6-3.noarch.rpm
yum -y install postgresql96 postgresql96-devel postgresql96-server postfix elasticsearch java cronie nginx which zammad

su - zammad /bin/bash -l -c "cd /opt/zammad && cp config/database.yml.dist config/database.yml"

su - zammad /bin/bash -l -c "cd /opt/zammad && echo 'production:' > config/database.yml"
su - zammad /bin/bash -l -c "cd /opt/zammad && echo '  adapter: postgresql' >> config/database.yml"
su - zammad /bin/bash -l -c "cd /opt/zammad && echo '  database: zammad' >> config/database.yml"
su - zammad /bin/bash -l -c "cd /opt/zammad && echo '  pool: 50' >> config/database.yml"
su - zammad /bin/bash -l -c "cd /opt/zammad && echo '  timeout: 5000' >> config/database.yml"
su - zammad /bin/bash -l -c "cd /opt/zammad && echo '  username: zammad' >> config/database.yml"
su - zammad /bin/bash -l -c "cd /opt/zammad && echo '  password:' >> config/database.yml"

# setup DB
/bin/bash -l -c "service postgresql-9.6 initdb"
/bin/bash -l -c "echo 'max_connections = 200' >> /var/lib/pgsql/9.6/data/postgresql.conf"
/bin/bash -l -c "echo 'shared_buffers = 2GB' >> /var/lib/pgsql/9.6/data/postgresql.conf"
/bin/bash -l -c "echo 'temp_buffers = 1GB' >> /var/lib/pgsql/9.6/data/postgresql.conf"
/bin/bash -l -c "echo 'work_mem = 6MB' >> /var/lib/pgsql/9.6/data/postgresql.conf"
/bin/bash -l -c "echo 'max_stack_depth = 2MB' >> /var/lib/pgsql/9.6/data/postgresql.conf"
/bin/bash -l -c "service postgresql-9.6 start && su - postgres -c 'createuser -s zammad'"

# TMP FIX
/bin/bash -l -c "usermod -d /opt/zammad zammad"
/bin/bash -l -c "service postgresql-9.6 start && su - zammad -c 'export RAILS_ENV=production && cd /opt/zammad && export PATH=/opt/zammad/bin:$PATH && export GEM_PATH=/opt/zammad/vendor/bundle/ruby/2.3.0/ && rake db:create && rake db:migrate && rake db:seed'"

# TMP FIX set up nginx (should be own package)
/bin/bash -l -c "rm -rf /etc/nginx/conf.d/*"
su - zammad /bin/bash -l -c "sed -i.bak '/server_name\syour\.domain\.org;/d' /opt/zammad/contrib/nginx/sites-enabled/zammad.conf"
/bin/bash -l -c "cp /opt/zammad/contrib/nginx/sites-enabled/zammad.conf /etc/nginx/conf.d/"


/bin/bash -l -c "cd /usr/share/elasticsearch && bin/plugin -install elasticsearch/elasticsearch-mapper-attachments/2.5.0"


chmod +x /tmp/setup.sh
chown zammad /tmp/setup.sh

# issue#7 - Elasticsearch not ready in docker.sh at execution of setup.sh - sleep 10 until
#           elasticsearch is accepting network connections
/bin/bash -l -c "service postgresql-9.6 start && service elasticsearch start && sleep 10 && su - zammad -c '/tmp/setup.sh'"

chmod +x /run.sh