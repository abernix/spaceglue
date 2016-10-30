#!/bin/sh
set -e
my_dir=`dirname $0`
. ${my_dir}/lib.sh

check_images_set

base_app_name="spaceglue-test-no_app"

clean() {
  docker rm -f "${base_app_name}" 2> /dev/null || true
}

trap "echo Failed: Missing Bundle Scenario && exit 1" EXIT

cd /tmp
clean

echo "=> Testing Missing Bundle Scenario"

docker run -d \
    --name "${base_app_name}" \
    -e ROOT_URL=http://no_app \
    "${DOCKER_IMAGE_NAME_BASE}"

docker_logs_has "${base_app_name}" "You don't have an meteor app"

trap - EXIT
clean

set +e
