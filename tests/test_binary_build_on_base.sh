#!/bin/sh

: ${NODE_VERSION?"NODE_VERSION has not been set."}

set -x

function clean() {
  docker rm -f binary_build
}

cd /tmp
clean

docker run -d \
    --name binary_build \
    -e ROOT_URL=http://binary_build_app \
    -e BUNDLE_URL=https://abernix-meteord-tests.s3-us-west-2.amazonaws.com/meteord-test-bundle.tar.gz \
    -e REBUILD_NPM_MODULES=1 \
    -p 9090:80 \
    "abernix/meteord:base-node-${NODE_VERSION}"

echo "Waiting for binary building is happening"
sleep 80

appContent=`docker logs binary_build`
clean

if [[ $appContent != *"abernix/meteord:bin-build"* ]]; then
  echo "Failed: Trying to binary building on the base image"
  exit 1
fi
