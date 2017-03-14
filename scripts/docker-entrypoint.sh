#!/bin/bash

set -e

if [ "$1" = 'zammad' ]; then

  # starting services
  service postgresql start
  service elasticsearch start
  service postfix start
  service nginx start

  # wait for postgres processe coming up
  until su - postgres -c 'psql -c "select version()"' &> /dev/null; do
    echo "waiting for postgres to be ready..."
    sleep 2
  done

  cd ${ZAMMAD_DIR}
  echo "starting zammad...."
  su -c "bundle exec script/websocket-server.rb -b 0.0.0.0 start &>> ${ZAMMAD_DIR}/log/zammad.log &" zammad
  su -c "bundle exec script/scheduler.rb start &>> ${ZAMMAD_DIR}/log/zammad.log &" zammad

  if [ "${RAILS_SERVER}" == "puma" ]; then
    su -c "bundle exec puma -b tcp://0.0.0.0:3000 -e ${RAILS_ENV} &>> ${ZAMMAD_DIR}/log/zammad.log &" zammad
  elif [ "${RAILS_SERVER}" == "unicorn" ]; then
    su -c "bundle exec unicorn -p 3000 -c config/unicorn.rb -E ${RAILS_ENV} &>> ${ZAMMAD_DIR}/log/zammad.log &" zammad
  fi

  # wait for zammad processe coming up
  until (echo > /dev/tcp/localhost/3000) &> /dev/null; do
    echo "waiting for zammad to be ready..."
    sleep 2
  done

  # show url
  echo -e "\nZammad is ready! Visit http://localhost in your browser!"
  echo -e "If you like to use Zammad from somewhere else edit servername directive in /etc/nginx/sites-enabled/zammad.conf!\n"

  # run shell
  /bin/bash

fi
