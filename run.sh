#!/bin/bash

service mysqld start
service elasticsearch start
service postfix start

# scheduler
zammad run worker start &

# websockets
zammad run websocket start &

# puma
# zammad run web start &
export PATH=/opt/zammad/bin:$PATH && export GEM_PATH=/opt/zammad/vendor/bundle/ruby/2.2.0/ && ./vendor/bundle/ruby/2.2.0/bin/puma -e production -p 3000 &

service nginx start

/bin/bash

# export PATH=/opt/zammad/bin:$PATH && export GEM_PATH=/opt/zammad/vendor/bundle/ruby/2.2.0/ && ./vendor/bundle/ruby/2.2.0/bin/puma -e production -p 3000