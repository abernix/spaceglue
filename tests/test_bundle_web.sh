#!/bin/sh
set -x
set -e
my_dir=`dirname $0`
. ${my_dir}/lib.sh

base_app_name="meteord-test-web"

clean() {
  docker rm -f meteord-test-web 2> /dev/null || true
}

trap "echo Failed: Bundle web" EXIT

cd /tmp
clean

test_root_url_hostname="web_app"

docker run -d \
    --name "${base_app_name}" \
    -e ROOT_URL=http://$test_root_url_hostname \
    -e BUNDLE_URL=https://abernix-meteord-tests.s3-us-west-2.amazonaws.com/meteord-test-bundle.tar.gz \
    -p 9090:80 \
    "abernix/meteord:base"

watch_docker_logs_for_app_ready
sleep 1

check_server_for "9090" "${test_root_url_hostname}" || true

trap - EXIT
clean
