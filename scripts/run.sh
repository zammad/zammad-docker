#!/bin/bash

service postgresql-9.6 start
service elasticsearch start
service postfix start

# wait until postgres is ready
until su - postgres -c 'psql -c "select version()"' &> /dev/null
do
    echo "waiting for postgres to be ready..."
    sleep 20
done

# scheduler
zammad run worker start &

# websockets
zammad run websocket start &

# puma
# zammad run web start &
su - zammad -c 'export PATH=/opt/zammad/bin:$PATH && export GEM_PATH=/opt/zammad/vendor/bundle/ruby/2.3.0/ && ./vendor/bundle/ruby/2.3.0/bin/puma -e production -p 3000' &

service nginx start

/bin/bash

# export PATH=/opt/zammad/bin:$PATH && export GEM_PATH=/opt/zammad/vendor/bundle/ruby/2.3.0/ && ./vendor/bundle/ruby/2.3.0/bin/puma -e production -p 3000