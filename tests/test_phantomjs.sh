#!/bin/sh
set -x
set -e
my_dir=`dirname $0`
. ${my_dir}/lib.sh

base_app_name="meteord-test-phantomjs_check"

clean() {
  docker rm -f "${base_app_name}" 2> /dev/null || true
}

trap "echo Failed: Phantomjs Check" EXIT

clean

docker run  \
    --name "${base_app_name}" \
    --entrypoint="phantomjs -h" \
    "abernix/meteord:base"

sleep 5

docker_logs_has "${base_app_name}" "GhostDriver"

trap - EXIT
clean
