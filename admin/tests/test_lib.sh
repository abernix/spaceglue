#!/bin/sh

watch_token="=====METEORD_TEST====="

doalarm() { perl -e 'alarm shift; exec @ARGV' "$@"; }

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
