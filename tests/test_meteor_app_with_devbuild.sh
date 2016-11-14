#!/bin/sh

: ${NODE_VERSION?"NODE_VERSION has not been set."}

set -x

function clean() {
  docker rm -f meteor-app
  docker rmi -f meteor-app-image
  rm -rf hello
}

cd /tmp
clean

meteor create hello
cd hello
echo "FROM abernix/meteord:devbuild-node-${NODE_VERSION}" > Dockerfile

docker build -t meteor-app-image ./
docker run -d \
    --name meteor-app \
    -e ROOT_URL=http://yourapp_dot_com \
    -p 8080:80 \
    meteor-app-image

sleep 5

appContent=`curl http://localhost:8080`
clean

if [[ $appContent != *"yourapp_dot_com"* ]]; then
  echo "Failed: Meteor app"
  exit 1
fi