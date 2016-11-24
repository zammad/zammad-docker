#!/bin/bash

# starting services
service postgresql start
service elasticsearch start
service postfix start
service nginx start

# wait for postgresql coming up
until su - postgres -c 'psql -c "select version()"' &> /dev/null
do
    echo "waiting for postgres to be ready..."
    sleep 5
done

# run zammad
zammad run worker &>> /opt/zammad/log/zammad.log &
zammad run websocket &>> /opt/zammad/log/zammad.log &
zammad run web &>> /opt/zammad/log/zammad.log &

# show url
sleep 10
echo -e "\nZammad is ready! Visit http://localhost in your browser!"
echo -e "If you like to use Zammad from somewhere else edit servername directive in /etc/nginx/sites-enabled/zammad.conf!\n"

# run shell
/bin/bash

