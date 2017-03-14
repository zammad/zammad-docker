#!/bin/bash

set -ex

# set env
export DEBIAN_FRONTEND=noninteractive

# adding backport (openjdk)
echo "deb http://ftp.de.debian.org/debian jessie-backports main" > /etc/apt/sources.list.d/backports.list

# updating package list
apt-get update

# fix java - see https://bugs.debian.org/775775 and https://github.com/docker-library/java/issues/19#issuecomment-70546872
JAVA_DEBIAN_VERSION="8u121-b13-1~bpo8+1"
CA_CERTIFICATES_JAVA_VERSION="20161107~bpo8+1"

# install dependencies
apt-get --no-install-recommends -y install apt-transport-https libterm-readline-perl-perl locales mc net-tools nginx openjdk-8-jre openjdk-8-jre-headless="$JAVA_DEBIAN_VERSION" ca-certificates-java="$CA_CERTIFICATES_JAVA_VERSION"

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
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-5.x.list

# updating package list again
apt-get update

# install elasticsearch & attachment plugin
update-ca-certificates -f
apt-get --no-install-recommends -y install elasticsearch
cd /usr/share/elasticsearch && bin/elasticsearch-plugin install mapper-attachments
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
sed -e "s#production:#${RAILS_ENV}:#" -e "s#.*adapter:.*#  adapter: postgresql#" -e "s#.*username:.*#  username: ${ZAMMAD_DB_USER}#" -e "s#.*password:.*#  password: ${ZAMMAD_DB_PASS}#" -e "s#.*database:.*#  database: ${ZAMMAD_DB}\n  host: localhost#" < ${ZAMMAD_DIR}/config/database.yml.pkgr > ${ZAMMAD_DIR}/config/database.yml

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

# copy nginx zammad config
cp ${ZAMMAD_DIR}/contrib/nginx/zammad.conf /etc/nginx/sites-enabled/zammad.conf

# set user & group to zammad
chown -R zammad:zammad "${ZAMMAD_DIR}"
