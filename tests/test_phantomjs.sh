#!/bin/sh

: ${NODE_VERSION?"NODE_VERSION has not been set."}

set -x

function clean() {
  docker rm -f phantomjs_check
}

clean
docker run  \
    --name phantomjs_check \
    --entrypoint="/bin/sh" \
    "abernix/meteord:base-node-${NODE_VERSION}" -c 'phantomjs -h'

sleep 5

appContent=`docker logs phantomjs_check`
clean

if [[ $appContent != *"GhostDriver"* ]]; then
  echo "Failed: Phantomjs Check"
  exit 1
fi