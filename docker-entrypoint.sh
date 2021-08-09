#!/bin/bash

set -e

if [ "$1" = 'zammad' ]; then
  echo -e "\n Starting services... \n"

  # starting services
  service postgresql start
  service elasticsearch start
  service postfix start
  service memcached start
  service redis-server start
  service nginx start

  # wait for postgres processe coming up
  until su - postgres -c 'psql -c "select version()"' &> /dev/null; do
    echo "Waiting for PostgreSQL to be ready..."
    sleep 2
  done

  cd "${ZAMMAD_DIR}"

  echo -e "\n Starting Zammad... \n"
  su -c "bundle exec script/websocket-server.rb -b 0.0.0.0 start &" zammad
  su -c "bundle exec script/scheduler.rb start &" zammad

  # show url
  echo -e "\nZammad will be ready in some seconds! Visit http://localhost in your browser!"

  # start railsserver
  if [ "${RAILS_SERVER}" == "puma" ]; then
    su -c "bundle exec puma -b tcp://0.0.0.0:3000 -e ${RAILS_ENV}" zammad
  elif [ "${RAILS_SERVER}" == "unicorn" ]; then
    su -c "bundle exec unicorn -p 3000 -c config/unicorn.rb -E ${RAILS_ENV}" zammad
  fi
fi
