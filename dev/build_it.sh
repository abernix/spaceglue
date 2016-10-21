#!/bin/sh

set -x

: ${NODE_VERSION?"must be set."}
: ${IMAGE_NAME:=abernix/spaceglue}
: ${IMAGE_TAG:=base}

DOCKER_IMAGE_NAME_BASE="${IMAGE_NAME}:node-${NODE_VERSION}"
DOCKER_IMAGE_NAME_ONBUILD="${DOCKER_IMAGE_NAME_BASE}-onbuild"

if [ -z "$FINAL_BUILD" ]; then
  test_build_hash="-$(date | (md5sum || md5) | head -c10)"

  DOCKER_IMAGE_NAME_BASE="${DOCKER_IMAGE_NAME_BASE}${test_build_hash}"
  DOCKER_IMAGE_NAME_ONBUILD="${DOCKER_IMAGE_NAME_ONBUILD}${test_build_hash}"
fi

my_dir=`dirname $0`
root_dir="$my_dir/.."

# Run as a subshell to avoid polluting `my_dir` up.
(

  trap "echo Failed: Could not build docker images" EXIT

  docker build \
      -t "${DOCKER_IMAGE_NAME_BASE}" \
      ${root_dir}/base

  onbuild_dockerfile="${root_dir}/onbuild/Dockerfile.from.$(
      echo ${DOCKER_IMAGE_NAME_BASE} | tr '/:' '_'
  )"

  sed "s|^FROM .*$|FROM ${DOCKER_IMAGE_NAME_BASE}|" \
    "${root_dir}/onbuild/Dockerfile" > \
    "${onbuild_dockerfile}"

  docker build \
      -t "${DOCKER_IMAGE_NAME_ONBUILD}" \
      -f "${onbuild_dockerfile}" \
      ${root_dir}/onbuild

  trap - EXIT
  rm -f "${onbuild_dockerfile}"
)

set +x