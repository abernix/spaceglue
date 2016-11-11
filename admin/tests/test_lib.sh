#!/bin/sh

watch_token="=====METEORD_TEST====="

doalarm() { perl -e 'alarm shift; exec @ARGV' "$@"; }

cver () {
  echo $1 | perl -n \
  -e '@ver = /^(?:[^\@]+\@)?([0-9]+)\.([0-9]+)(?:\.([0-9]+))?(?:\.([0-9]+))?/;' \
  -e 'printf "%04s%04s%04s%04s", @ver;'
}

check_images_set () {
  : ${DOCKER_IMAGE_NAME_BASE?"has not been set."}
  : ${DOCKER_IMAGE_NAME_BUILDDEPS?"has not been set."}
  : ${DOCKER_IMAGE_NAME_ONBUILD?"has not been set."}
}

add_binary_dependency () {
  target_file=${1:-"server/main.js"}
  echo "    => Adding binary dependency to ${target_file}"
  echo "      => Adding 'npm-bcrypt' package to app"
  meteor add npm-bcrypt 2>&1 > /dev/null
  echo "      => Installing 'bcrypt' NPM (with binary node bindings)"
  meteor npm install bcrypt --save 2>&1 > /dev/null
  cat <<EOM >> $target_file
    require('meteor/meteor').Meteor.startup(() => {
      console.log('bcrypt:::' + require('bcrypt').hashSync("asdf", 10) + ':::');
    });
EOM
}

add_watch_token () {
  target_file=${1:-"server/__11_first.js"}
  echo "    => Adding watch token to ${target_file}..."
  cat <<EOM >> $target_file
    require('meteor/meteor').Meteor.startup(() => console.log('$watch_token'));
EOM
}

create_meteor_test_app () {
  test_app_name=${1:-generic_app}
  test_app_version=$2

  if ! [ -z "${test_app_version}" ] && [ -n "${test_app_version}" ]; then
    echo "=> Creating Test App for Meteor ${test_app_version:-}..."
    test_app_release_argument="--release ${test_app_version}"
  else
    echo "=> Creating Test App with Default Meteor..."
    test_app_release_argument=""
  fi

  meteor create ${test_app_release_argument} "${test_app_name}" 2>&1 > /dev/null
  cd "${test_app_name}"
  if [ -z "${test_app_version}" ] || \
    [ $(cver "${test_app_version}") -ge $(cver "1.4") ]; then
    echo "  => Installing 'babel-runtime' NPM..."
    meteor npm install babel-runtime --save
  fi
  add_watch_token
  add_binary_dependency
  echo "  => Done creating test app!"
}

docker_dump_logs () {
  # Only prints logs if the container exists and has anything to print.
  docker inspect $1 > /dev/null 2>&1 && docker logs $1 2>&1 || true
}

docker_logs_has () {
  echo "    => Watching Docker Logs on $1 for '${2}'"
  docker logs "$1" 2>&1 | grep "$2"
}

docker_logs_has_bcrypt_token () {
  echo "    => Checking Docker Logs for Bcrypt token"
  docker logs "$1" 2>&1 | \
    grep -E --quiet \
      '^bcrypt:::\$2[ay]?\$[0-9]{1,2}\$[^\$]{53}:::$' 2>&1 > /dev/null
}

watch_docker_logs_for () {
  echo "    => Watching Docker Logs on $1 for '${2}'"
  doalarm ${3:-60} sh -c "\
    docker logs -f $1 2>/dev/null | \
    grep --line-buffered --max-count=1 --quiet "'"'"$2"'"'
}

watch_docker_logs_for_app_ready () {
  watch_docker_logs_for "$1" "=> Starting meteor app on port"
}

watch_docker_logs_for_token () {
  watch_docker_logs_for "$1" "${watch_token}"
}

check_server_for () {
  check_url="http://localhost:$1"
  echo "    => Checking ${check_url} for ${2}..."
  curl -s ${check_url} | grep "${2}" 2>&1 > /dev/null
}
