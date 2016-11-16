#!/bin/bash

#/bin/bash -l -c "echo 'max_connections = 200' >> /etc/postgresql/9.5/main/postgresql.conf"
#/bin/bash -l -c "echo 'shared_buffers = 2GB' >> /etc/postgresql/9.5/main/postgresql.conf"
#/bin/bash -l -c "echo 'temp_buffers = 1GB' >> /etc/postgresql/9.5/main/postgresql.conf"
#/bin/bash -l -c "echo 'work_mem = 6MB' >> /etc/postgresql/9.5/main/postgresql.conf"
#/bin/bash -l -c "echo 'max_stack_depth = 2MB' >> /etc/postgresql/9.5/main/postgresql.conf"

#service restart postgresql

chmod +x /tmp/setup.sh
chown zammad /tmp/setup.sh

# issue#7 - Elasticsearch not ready in docker.sh at execution of setup.sh - sleep 10 until
#           elasticsearch is accepting network connections
#/bin/bash -l -c "service start postgresql && service start elasticsearch && sleep 10 && su - zammad -c '/tmp/setup.sh'"

chmod +x /run.sh
