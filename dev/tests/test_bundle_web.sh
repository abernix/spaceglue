#!/bin/sh
set -x
set -e
my_dir=`dirname $0`
. ${my_dir}/lib.sh

check_images_set

base_app_name="meteord-test-web"

clean() {
  docker rm -f meteord-test-web 2> /dev/null || true
}

trap "echo Failed: Bundle web" EXIT

cd /tmp
clean

test_root_url_hostname="web_app"

export BUNDLE_URL=https://abernix-meteord-tests.s3-us-west-2.amazonaws.com/meteor-1.4.1.3.tar.gz

docker run -d \
    --name "${base_app_name}" \
    -e ROOT_URL=http://$test_root_url_hostname \
    -e BUNDLE_URL \
    -p 63836:80 \
    "${DOCKER_IMAGE_NAME_BASE}"

sleep 1
watch_docker_logs_for_token "${base_app_name}"
sleep 1
check_server_for "63836" "${test_root_url_hostname}"

trap - EXIT
clean
