#!/bin/sh
set -x
set -e
my_dir=`dirname $0`
. ${my_dir}/lib.sh

check_images_set

base_app_name="meteord-test-app"

clean() {
  docker rm -f "${base_app_name}" 2> /dev/null || true
  docker rmi -f "${base_app_image_name}" 2> /dev/null || true
  rm -rf ${base_app_name} || true
}

trap "echo Failed: Meteor app" EXIT

base_app_image_name="${base_app_name}-image"

cd /tmp
clean

if ! [ -z "$1" ] && [ -n "$1" ]; then
  echo "Testing Meteor $1"
  release_argument="--release $1"
  if [ $(cver "$1") -ge $(cver "1.4.2") ]; then
    unsafe_perm_flag="--unsafe-perm"
  else
    unsafe_perm_flag=""
  fi
else
  release_argument=""
  unsafe_perm_flag="--unsafe-perm"
fi

meteor create ${release_argument} "${base_app_name}" 2>&1 > /dev/null
cd "${base_app_name}"
add_watch_token
add_binary_dependency

echo "FROM ${DOCKER_IMAGE_NAME_ONBUILD}" > Dockerfile

test_root_url_hostname="yourapp_dot_com"

docker build -t "${base_app_image_name}" .
docker run -d \
    --name "${base_app_name}" \
    -e ROOT_URL=http://$test_root_url_hostname \
    -p 63836:80 \
    "${base_app_image_name}"

sleep 1
watch_docker_logs_for_token "${base_app_name}"
sleep 1
! docker_logs_has "${base_app_name}" "you are using a pure-JavaScript"
docker_logs_has_bcrypt_token "${base_app_name}"
check_server_for "63836" "${test_root_url_hostname}"

trap - EXIT
clean
