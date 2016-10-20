#!/bin/sh
set -x
set -e
my_dir=`dirname $0`
. ${my_dir}/lib.sh

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

meteor create "${base_app_name}"
cd "${base_app_name}"

echo "FROM abernix/meteord:base" > Dockerfile

add_watch_token "server/main.js"

test_root_url_hostname="yourapp_dot_com"

docker build -t "${base_app_image_name}" ./
docker run -d \
    --name "${base_app_name}" \
    -e ROOT_URL=http://$test_root_url_hostname \
    -p 8080:80 \
    "${base_app_image_name}"

watch_docker_logs_for_token "${base_app_name}" || true
sleep 1

check_server_for "8080" "${test_root_url_hostname}" || true

trap - EXIT
clean
