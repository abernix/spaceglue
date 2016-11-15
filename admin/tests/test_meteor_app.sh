#!/bin/sh
set -e
my_dir=`dirname $0`
admin_dir="$my_dir/.."

. ${admin_dir}/lib.sh
. ${my_dir}/test_lib.sh

check_images_set

base_app_name="spaceglue-test-app"

clean() {
  docker rm -f "${base_app_name}" 2> /dev/null || true
  docker rmi -f "${base_app_image_name}" 2> /dev/null || true
  rm -rf "${base_app_name}" || true
}

meteor_version=$1
meteor_version_label="${1:-default}"

on_trap_exit () {
  docker_dump_logs ${base_app_name}
  echo Failed: "Meteor ${meteor_version_label} app build"
  exit 1
}

trap 'on_trap_exit' EXIT

base_app_image_name="${base_app_name}-image"

cd /tmp
clean

create_meteor_test_app "${base_app_name}" "${meteor_version}"

echo "FROM ${DOCKER_IMAGE_NAME_ONBUILD}" > Dockerfile

test_root_url_hostname="yourapp_dot_com"

echo "  => Building Meteor ${meteor_version:-}"
docker build -t "${base_app_image_name}" . 2>&1 > /dev/null
docker run -d \
    --name "${base_app_name}" \
    -e ROOT_URL=http://$test_root_url_hostname \
    -p 63836:80 \
    "${base_app_image_name}"

watch_docker_logs_for_token "${base_app_name}"
! docker_logs_has "${base_app_name}" "you are using a pure-JavaScript"
docker_logs_has_bcrypt_token "${base_app_name}"
check_server_for "63836" "${test_root_url_hostname}"

# Clear trap
trap - EXIT

clean

set +e
