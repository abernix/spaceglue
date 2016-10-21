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
  : ${DOCKER_IMAGE_NAME_ONBUILD?"has not been set."}
}

add_binary_dependency () {
  meteor add npm-bcrypt
  meteor npm install bcrypt --save
  cat <<EOM >> ${1:-"server/main.js"}
    require('meteor/meteor').Meteor.startup(() => {
      console.log('bcrypt:::' + require('bcrypt').hashSync("asdf", 10) + ':::');
    });
EOM
}

add_watch_token () {
  cat <<EOM >> ${1:-"server/__11_first.js"}
    require('meteor/meteor').Meteor.startup(() => console.log('$watch_token'));
EOM
}

docker_logs_has () {
  docker logs "$1" | grep "$2"
}

docker_logs_has_bcrypt_token () {
  docker logs "$1" | grep -E '^bcrypt:::\$2[ay]?\$[0-9]{1,2}\$[^\$]{53}:::$'
}

watch_docker_logs_for () {
  doalarm ${3:-120} sh -c "docker logs -f '$1' | grep --line-buffered -m1 '$2'"
}

watch_docker_logs_for_app_ready () {
  watch_docker_logs_for "$1" "=> Starting meteor app on port"
}

watch_docker_logs_for_token () {
  watch_docker_logs_for "$1" "${watch_token}"
}

check_server_for () {
  curl -s "http://localhost:$1" | grep "${2}" 2>&1 > /dev/null
}
