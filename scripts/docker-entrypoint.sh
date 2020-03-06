#!/bin/bash

set -e

if [ "$1" = 'zammad' ]; then

  echo -e "\n Starting services... \n"

  # starting services
  service postgresql start
  service elasticsearch start
  service postfix start
  service memcached start
  service nginx start

  # wait for postgres processe coming up
  until su - postgres -c 'psql -c "select version()"' &> /dev/null; do
    echo "Waiting for PostgreSQL to be ready..."
    sleep 2
  done

  cd "${ZAMMAD_DIR}"

  echo -e "\n Starting Zammad... \n"
  su -c "bundle exec script/websocket-server.rb -b 0.0.0.0 start &>> ${ZAMMAD_DIR}/log/zammad.log &" zammad
  su -c "bundle exec script/scheduler.rb start &>> ${ZAMMAD_DIR}/log/zammad.log &" zammad

  if [ "${RAILS_SERVER}" == "puma" ]; then
    su -c "bundle exec puma -b tcp://0.0.0.0:3000 -e ${RAILS_ENV} &>> ${ZAMMAD_DIR}/log/zammad.log &" zammad
  elif [ "${RAILS_SERVER}" == "unicorn" ]; then
    su -c "bundle exec unicorn -p 3000 -c config/unicorn.rb -E ${RAILS_ENV} &>> ${ZAMMAD_DIR}/log/zammad.log &" zammad
  fi

  # wait for zammad processe coming up
  until (echo > /dev/tcp/localhost/3000) &> /dev/null; do
    echo "Waiting for Zammad to be ready..."
    sleep 2
  done

  # show url
  echo -e "\nZammad is ready! Visit http://localhost in your browser!"

  # run shell
  /bin/bash

fi
