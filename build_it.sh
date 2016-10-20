#!/bin/sh

set -x

: ${NODE_VERSION?"NODE_VERSION has not been set."}

my_dir=`dirname $0`

docker build \
    --build-arg "NODE_VERSION=${NODE_VERSION}" \
    -t "abernix/meteord:base-node-${NODE_VERSION}" \
    ${my_dir}/base \
  && \
    docker tag \
      "abernix/meteord:base-node-${NODE_VERSION}" \
      abernix/meteord:base
