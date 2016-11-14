#!/bin/sh

set -x

: ${NODE_VERSION?"NODE_VERSION has not been set."}

docker build --no-cache --build-arg "NODE_VERSION=${NODE_VERSION}" -t "abernix/meteord:base-node-${NODE_VERSION}" ../base && \
  docker tag "abernix/meteord:base-node-${NODE_VERSION}" abernix/meteord:base
docker build --no-cache --build-arg "NODE_VERSION=${NODE_VERSION}" -t "abernix/meteord:onbuild-node-${NODE_VERSION}" ../onbuild && \
  docker tag "abernix/meteord:onbuild-node-${NODE_VERSION}" abernix/meteord:onbuild
docker build --no-cache --build-arg "NODE_VERSION=${NODE_VERSION}" -t "abernix/meteord:devbuild-node-${NODE_VERSION}" ../devbuild && \
  docker tag "abernix/meteord:devbuild-node-${NODE_VERSION}" abernix/meteord:devbuild
docker build --no-cache --build-arg "NODE_VERSION=${NODE_VERSION}" -t "abernix/meteord:binbuild-node-${NODE_VERSION}" ../binbuild && \
  docker tag "abernix/meteord:binbuild-node-${NODE_VERSION}" abernix/meteord:binbuild
