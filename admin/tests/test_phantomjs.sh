#!/bin/sh
set -e
my_dir=`dirname $0`
. ${my_dir}/lib.sh

check_images_set

base_app_name="spaceglue-test-phantomjs_check"

clean() {
  docker rm -f "${base_app_name}" 2> /dev/null || true
}

trap "echo Failed: PhantomJS Support && exit 1" EXIT

clean

echo "=> Testing PhantomJS Support"

docker run  \
    --name "${base_app_name}" \
    --entrypoint=phantomjs \
    "${DOCKER_IMAGE_NAME_ONBUILD}" \
    --help

watch_docker_logs_for "${base_app_name}" "GhostDriver"

trap - EXIT
clean

set +e
