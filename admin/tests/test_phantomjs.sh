#!/bin/sh
set -e
my_dir=`dirname $0`
admin_dir="$my_dir/.."

. ${admin_dir}/lib.sh
. ${my_dir}/test_lib.sh

check_images_set

base_app_name="spaceglue-test-phantomjs_check"

clean() {
  docker rm -f "${base_app_name}" 2> /dev/null || true
}

on_trap_exit () {
  set +e
  docker_dump_logs ${base_app_name}
  echo "Failed: PhantomJS Support"
  exit 1
}

trap 'on_trap_exit' EXIT

clean

echo "=> Testing PhantomJS Support"

docker run  \
    --name "${base_app_name}" \
    --entrypoint=phantomjs \
    "${DOCKER_IMAGE_NAME_ONBUILD}" \
    --help

watch_docker_logs_for "${base_app_name}" "GhostDriver"

# Clear trap
trap - EXIT

clean

set +e
