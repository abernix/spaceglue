#!/bin/sh

: ${NODE_VERSION?"NODE_VERSION has not been set."}

set -x

function clean() {
  docker rm -f localmount
  rm -rf localmount
}

cd /tmp
clean

meteor create localmount
cd localmount
meteor build --architecture=os.linux.x86_64 ./
pwd
ls -la

docker run -d \
    --name localmount \
    -e ROOT_URL=http://localmount_app \
    -v /tmp/localmount:/bundle \
    -p 9090:80 \
    "abernix/meteord:base-node-${NODE_VERSION}"

sleep 50

appContent=`curl http://localhost:9090`
clean

if [[ $appContent != *"localmount_app"* ]]; then
  echo "Failed: Bundle local mount"
  exit 1
fi