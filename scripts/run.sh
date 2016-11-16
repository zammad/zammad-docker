#!/bin/bash

service postgresql start
service elasticsearch start
service postfix start
service nginx start

sleep 5

zammad run worker &>> /opt/zammad/log/zammad.log &
zammad run websocket &>> /opt/zammad/log/zammad.log &
zammad run web &>> /opt/zammad/log/zammad.log &

/bin/bash

