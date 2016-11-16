#!/bin/bash

wget -qO - https://deb.packager.io/key | sudo apt-key add -
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -

echo echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-5.x.list
echo "deb https://deb.packager.io/gh/zammad/zammad xenial stable" | sudo tee /etc/apt/sources.list.d/zammad.list

apt-get update
apt-get install nginx postgresql elasticsearch postfix cron zammad

/bin/bash -l -c "echo 'max_connections = 200' >> /etc/postgresql/9.5/main/postgresql.conf"
/bin/bash -l -c "echo 'shared_buffers = 2GB' >> /etc/postgresql/9.5/main/postgresql.conf"
/bin/bash -l -c "echo 'temp_buffers = 1GB' >> /etc/postgresql/9.5/main/postgresql.conf"
/bin/bash -l -c "echo 'work_mem = 6MB' >> /etc/postgresql/9.5/main/postgresql.conf"
/bin/bash -l -c "echo 'max_stack_depth = 2MB' >> /etc/postgresql/9.5/main/postgresql.conf"

/bin/bash -l -c "cd /usr/share/elasticsearch && bin/elasticsearch-plugin install mapper-attachments"

chmod +x /tmp/setup.sh
chown zammad /tmp/setup.sh

# issue#7 - Elasticsearch not ready in docker.sh at execution of setup.sh - sleep 10 until
#           elasticsearch is accepting network connections
/bin/bash -l -c "systemctl start postgresql && systemctl start elasticsearch && sleep 10 && su - zammad -c '/tmp/setup.sh'"

chmod +x /run.sh
