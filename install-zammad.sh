#!/bin/bash

set -ex

# set env
export DEBIAN_FRONTEND=noninteractive

# updating package list
apt-get update

# install dependencies
apt-get --no-install-recommends -y install apt-transport-https ca-certificates-java curl libimlib2 libimlib2-dev libterm-readline-perl-perl locales memcached net-tools nginx default-jdk shared-mime-info

# install postfix
echo "postfix postfix/main_mailer_type string Internet site" > preseed.txt
debconf-set-selections preseed.txt
apt-get --no-install-recommends install -q -y postfix

# install postgresql server
locale-gen en_US.UTF-8
localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
echo "LANG=en_US.UTF-8" > /etc/default/locale
apt-get --no-install-recommends install -q -y postgresql

# configure elasticsearch repo & key
curl -s -J -L -o - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
echo "deb https://artifacts.elastic.co/packages/oss-7.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-7.x.list

# updating package list again
apt-get update

# install elasticsearch & attachment plugin
update-ca-certificates -f
apt-get --no-install-recommends -y install elasticsearch-oss
cd /usr/share/elasticsearch && bin/elasticsearch-plugin install -b ingest-attachment
service elasticsearch start

# create zammad user
useradd -M -d "${ZAMMAD_DIR}" -s /bin/bash zammad

# git clone zammad
cd "$(dirname "${ZAMMAD_DIR}")"
git clone "${GIT_URL}"

# switch to git branch
cd "${ZAMMAD_DIR}"
git checkout "${GIT_BRANCH}"

# install zammad
if [ "${RAILS_ENV}" == "production" ]; then
  bundle install --without test development mysql
elif [ "${RAILS_ENV}" == "development" ]; then
  bundle install --without mysql
fi

# fetch locales
contrib/packager.io/fetch_locales.rb

# create db & user
ZAMMAD_DB_PASS="$(tr -dc A-Za-z0-9 < /dev/urandom | head -c10)"
su - postgres -c "createdb -E UTF8 ${ZAMMAD_DB}"
echo "CREATE USER \"${ZAMMAD_DB_USER}\" WITH PASSWORD '${ZAMMAD_DB_PASS}';" | su - postgres -c psql
echo "GRANT ALL PRIVILEGES ON DATABASE \"${ZAMMAD_DB}\" TO \"${ZAMMAD_DB_USER}\";" | su - postgres -c psql

# create database.yml
sed -e "s#production:#${RAILS_ENV}:#" -e "s#.*adapter:.*#  adapter: postgresql#" -e "s#.*username:.*#  username: ${ZAMMAD_DB_USER}#" -e "s#.*password:.*#  password: ${ZAMMAD_DB_PASS}#" -e "s#.*database:.*#  database: ${ZAMMAD_DB}\n  host: localhost#" < "${ZAMMAD_DIR}"/contrib/packager.io/database.yml.pkgr > "${ZAMMAD_DIR}"/config/database.yml

# enable memcached
sed -i -e "s/.*config.cache_store.*file_store.*cache_file_store.*/    config.cache_store = :dalli_store, '127.0.0.1:11211'\n    config.session_store = :dalli_store, '127.0.0.1:11211'/" config/application.rb

# populate database
bundle exec rake db:migrate
bundle exec rake db:seed

# assets precompile
bundle exec rake assets:precompile

# delete assets precompile cache
rm -r tmp/cache

# create es searchindex
bundle exec rails r "Setting.set('es_url', 'http://localhost:9200')"
bundle exec rake searchindex:rebuild

# create nginx zammad config
sed -e "s#server_name localhost#server_name _#g" < "${ZAMMAD_DIR}"/contrib/nginx/zammad.conf > /etc/nginx/sites-enabled/default
ln -sf /dev/stdout /var/log/nginx/access.log 
ln -sf /dev/stderr /var/log/nginx/error.log

# set user & group to zammad
chown -R "${ZAMMAD_USER}:${ZAMMAD_USER}" "${ZAMMAD_DIR}"
