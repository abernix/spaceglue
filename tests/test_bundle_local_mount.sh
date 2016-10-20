#!/bin/sh
set -x
set -e
my_dir=`dirname $0`
. ${my_dir}/lib.sh

base_app_name="meteord-test-localmount"

clean() {
  docker rm -f "${base_app_name}" 2> /dev/null || true
  rm -rf ${base_app_name} || true
}

trap "echo Failed: Bundle local mount" EXIT

cd /tmp
clean

meteor create "${base_app_name}"
cd "${base_app_name}"

meteor build --architecture=os.linux.x86_64 ./

test_root_url_hostname="localmount_app"

docker run -d \
    --name "${base_app_name}" \
    -e ROOT_URL=http://$test_root_url_hostname \
    -v "/tmp/${base_app_name}:/bundle" \
    -p 9090:80 \
    "abernix/meteord:base"

watch_docker_logs_for_app_ready
sleep 1

check_server_for "9090" "${test_root_url_hostname}" || true

trap - EXIT
clean
