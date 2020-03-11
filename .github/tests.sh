#!/bin/bash
#
# run zammad tests
#

set -o errexit
set -o pipefail

docker logs --timestamps --follow zammad-test &

until (curl -I --silent --fail localhost | grep -iq "HTTP/1.1 200 OK"); do
    echo "Wait for Zammad to be ready..."
    sleep 15
done

sleep 30

echo
echo "Success - Zammad is up :)"
echo
echo "Execute autowizard..."
echo

curl -I --silent --fail --show-error "http://localhost/#getting_started/auto_wizard/docker_compose_token" > /dev/null

echo 
echo "Autowizard executed successfully :)"
echo 

