#!/bin/sh
set -e
my_dir=`dirname $0`
admin_dir="$my_dir/.."

. ${admin_dir}/lib.sh
. ${my_dir}/test_lib.sh

check_images_set

base_app_name="spaceglue-test-no_app"

clean() {
  docker rm -f "${base_app_name}" 2> /dev/null || true
}

on_trap_exit () {
  set +e
  docker_dump_logs ${base_app_name}
  echo "Failed: Missing Bundle Scenario"
  exit 1
}

trap 'on_trap_exit' EXIT

cd /tmp
clean

echo "=> Testing Missing Bundle Scenario"

docker run -d \
    --name "${base_app_name}" \
    -e ROOT_URL=http://no_app \
    "${DOCKER_IMAGE_NAME_BASE}"

watch_docker_logs_for "${base_app_name}" "You don't have an meteor app"

# Clear trap
trap - EXIT

clean

set +e
