#!/bin/bash

export RAILS_ENV=production
export PATH=/opt/zammad/bin:$PATH
export GEM_PATH=/opt/zammad/vendor/bundle/ruby/2.3.0/

cd /opt/zammad
rails r "Setting.set('es_url', 'http://localhost:9200')"
sleep 15
rake searchindex:rebuild
