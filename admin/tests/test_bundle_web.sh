#!/bin/sh
set -e
my_dir=`dirname $0`
admin_dir="$my_dir/.."

. ${admin_dir}/lib.sh
. ${my_dir}/test_lib.sh

check_images_set

meteor_version=$1

if [ -z "${meteor_version}" ]; then
  echo "Please pass Meteor version number as the first argument."
  exit 1
fi

base_app_name="spaceglue-test-web-${meteor_version}"

clean() {
  docker rm -f "${base_app_name}" 2> /dev/null || true
}

on_trap_exit () {
  set +e
  docker_dump_logs ${base_app_name}
  echo "Failed: Meteor Bundle from Web"
  exit 1
}

trap 'on_trap_exit' EXIT

cd /tmp
clean

echo "=> Testing Meteor Bundle from Web (${meteor_version})"

test_root_url_hostname="web_app"
s3_uri_base="https://${s3_bucket_name}.s3-${s3_bucket_region}.amazonaws.com"

export BUNDLE_URL="${s3_uri_base}/meteor-${meteor_version}.tar.gz"

docker run -d \
    --name "${base_app_name}" \
    --cap-add NET_BIND_SERVICE \
    -e ROOT_URL=http://$test_root_url_hostname \
    -e BUNDLE_URL \
    -p 63836:80 \
    "${DOCKER_IMAGE_NAME_BUILDDEPS}"

watch_docker_logs_for_token "${base_app_name}"
! docker_logs_has "${base_app_name}" "you are using a pure-JavaScript"
docker_logs_has_bcrypt_token "${base_app_name}"
check_server_for "63836" "${test_root_url_hostname}"

# Clear trap
trap - EXIT

clean

set +e
