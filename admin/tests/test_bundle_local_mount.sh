#!/bin/sh
set -e
my_dir=`dirname $0`
admin_dir="$my_dir/.."

. ${admin_dir}/lib.sh
. ${my_dir}/test_lib.sh

check_images_set

base_app_name="spaceglue-test-localmount"

clean() {
  docker rm -f "${base_app_name}" 2> /dev/null || true
  rm -rf "${base_app_name}-bundle" || true
  rm -rf "${base_app_name}" || true
}

trap "echo Failed: Meteor Bundle Locally Mounted && exit 1" EXIT

cd /tmp
clean

echo "=> Testing Meteor Bundle Locally Mounted"

create_meteor_test_app "${base_app_name}"

test_root_url_hostname="localmount_app"
meteor build \
  --architecture=os.linux.x86_64 \
  "../${base_app_name}-bundle" \
  2>&1 > /dev/null

docker run -d \
    --name "${base_app_name}" \
    -e ROOT_URL=http://$test_root_url_hostname \
    -v "/tmp/${base_app_name}-bundle:/bundle" \
    -p 63836:3000 \
    "${DOCKER_IMAGE_NAME_BUILDDEPS}"

watch_docker_logs_for_token "${base_app_name}"
! docker_logs_has "${base_app_name}" "you are using a pure-JavaScript"
docker_logs_has_bcrypt_token "${base_app_name}"
check_server_for "63836" "${test_root_url_hostname}"

trap - EXIT
clean

set +e
