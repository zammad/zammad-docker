#!/bin/bash

service postgresql start
service elasticsearch start
service postfix start

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