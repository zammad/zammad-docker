#!/bin/bash

if [ "$1" = 'zammad' ]; then

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

    # wait for elasticsearch coming up
    until curl -GET localhost:9200 &> /dev/null
    do
	echo "waiting for elasticsearch to be ready..."
	sleep 5
    done

    # build elasticsearch search index
    zammad run rails r "Setting.set('es_url', 'http://localhost:9200')"
    zammad run rake searchindex:rebuild

    # run zammad
    zammad run worker &>> /opt/zammad/log/zammad.log &
    zammad run websocket &>> /opt/zammad/log/zammad.log &
    zammad run web &>> /opt/zammad/log/zammad.log &

    until curl -GET localhost:3000 &> /dev/null
    do
	echo "waiting for zammad to be ready..."
	sleep 5
    done

    # show url
    echo -e "\nZammad is ready! Visit http://localhost in your browser!"
    echo -e "If you like to use Zammad from somewhere else edit servername directive in /etc/nginx/sites-enabled/zammad.conf!\n"

    # run shell
    /bin/bash

fi
