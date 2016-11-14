#!/bin/sh

: ${NODE_VERSION?"NODE_VERSION has not been set."}

set -x

function clean() {
  docker rm -f web
}

cd /tmp
clean

docker run -d \
    --name web \
    -e ROOT_URL=http://web_app \
    -e BUNDLE_URL=https://abernix-meteord-tests.s3-us-west-2.amazonaws.com/meteord-test-bundle.tar.gz \
    -p 9090:80 \
    "abernix/meteord:base-node-${NODE_VERSION}"

sleep 50

appContent=`curl http://localhost:9090`
clean

if [[ $appContent != *"web_app"* ]]; then
  echo "Failed: Bundle web"
  exit 1
fi