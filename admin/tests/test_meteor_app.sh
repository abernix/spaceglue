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

trap "echo Failed: Meteor ${meteor_version_label} app build && exit 1" EXIT

base_app_image_name="${base_app_name}-image"

cd /tmp
clean

if ! [ -z "${meteor_version}" ] && [ -n "${meteor_version}" ]; then
  echo "=> Testing Meteor ${meteor_version:-}"
  release_argument="--release ${meteor_version}"
else
  echo "=> Testing 'recommended' (default) Meteor version"
  release_argument=""
fi

echo "  => Creating Meteor ${meteor_version:-} App"
meteor create ${release_argument} "${base_app_name}" 2>&1 > /dev/null
cd "${base_app_name}"
add_watch_token
add_binary_dependency

echo "FROM ${DOCKER_IMAGE_NAME_ONBUILD}" > Dockerfile

test_root_url_hostname="yourapp_dot_com"

echo "  => Building Meteor ${meteor_version:-}"
docker build -t "${base_app_image_name}" . 2>&1 > /dev/null
docker run -d \
    --name "${base_app_name}" \
    -e ROOT_URL=http://$test_root_url_hostname \
    -p 63836:3000 \
    "${base_app_image_name}"

watch_docker_logs_for_token "${base_app_name}"
! docker_logs_has "${base_app_name}" "you are using a pure-JavaScript"
docker_logs_has_bcrypt_token "${base_app_name}"
check_server_for "63836" "${test_root_url_hostname}"

trap - EXIT
clean

set +e
