#!/bin/sh

set -e

: ${NODE_VERSION?"must be set."}
: ${IMAGE_NAME:=abernix/spaceglue}
: ${IMAGE_TAG:=base}

name_base="${IMAGE_NAME}:node-${NODE_VERSION}"

if ! [ -z "$TEST_BUILD" ]; then
  test_build_hash="-$(head -c 100 /dev/urandom | (md5sum || md5) | head -c10)"
else
  test_build_hash=""
fi

my_dir=`dirname $0`
root_dir="$my_dir/.."

build_image_derivative () {
  base=$1
  derivative=$2

  derivative_dockerfile="${root_dir}/images/${derivative}/Dockerfile.generated"

  cleanup_derivative () {
    rm -f "${derivative_dockerfile}" || true
  }

  trap "cleanup_derivative && echo Failed: Could not build '${derivative}' image" EXIT

  sed \
    -e "s|^FROM ${IMAGE_NAME}:base|PRESERVE_BASE|" \
    -e "s|^FROM ${IMAGE_NAME}:|FROM ${base}-|" \
    -e "s|^FROM \(${IMAGE_NAME}:.*\)$|FROM \1${test_build_hash}|" \
    -e "s|PRESERVE_BASE|FROM ${base}${test_build_hash}|" \
    "${root_dir}/images/${derivative}/Dockerfile" > \
    "${derivative_dockerfile}"

  derivative_tag="${base}-${derivative}${test_build_hash}"

  docker build \
      -t "${derivative_tag}" \
      -f "${derivative_dockerfile}" \
      "${root_dir}/images/${derivative}" >&2

  echo "${derivative_tag}"

  trap - EXIT
  cleanup_derivative
}

DOCKER_IMAGE_NAME_BASE="${name_base}${test_build_hash}"
docker build \
    -t "${DOCKER_IMAGE_NAME_BASE}" \
    ${root_dir}/images/base

DOCKER_IMAGE_NAME_BUILDDEPS="$(build_image_derivative ${name_base} builddeps)"
DOCKER_IMAGE_NAME_ONBUILD="$(build_image_derivative ${name_base} onbuild)"

set +e
