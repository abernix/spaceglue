#!/bin/sh

set -e

if [ -d /bundle ]; then
  cd /bundle
  tar xzf *.tar.gz
  cd /bundle/bundle/programs/server/
  npm install --unsafe-perm
  cd /bundle/bundle/
elif [[ $BUNDLE_URL ]]; then
  cd /tmp
  curl -L -o bundle.tar.gz $BUNDLE_URL
  tar xzf bundle.tar.gz
  cd /tmp/bundle/programs/server/
  npm install --unsafe-perm
  cd /tmp/bundle/
elif [ -d /built_app ]; then
  cd /built_app
else
  echo "=> You don't have an meteor app to run in this image."
  exit 1
fi

if [[ $REBUILD_NPM_MODULES ]]; then
  echo "=> abernix/meteord:bin-build is NOT TESTED AT ALL (and maybe not necessary???)"
  echo "     Since Meteor handles rebuilding binary dependencies itself now, it's not entirely"
  echo "     clear to me if this particular image is still necessary.  If you are receiving"
  echo "     this message, I highly recommend trying the :base image without the REBUILD_NPM_MODULES"
  echo "     environment variable and see if it works for you.  Please report back as I'd like to"
  echo "     discourage use of the :bin-build image if possible!  Thanks! -abernix"
  if [ -f /opt/meteord/rebuild_npm_modules.sh ]; then
    cd programs/server
    /opt/meteord/rebuild_npm_modules.sh
    cd ../../
  else
    echo "=> Use abernix/meteord:bin-build for binary bulding."
    exit 1
  fi
fi

# Set a delay to wait to start meteor container
if [[ $DELAY ]]; then
  echo "Delaying startup for $DELAY seconds"
  sleep $DELAY
fi

# Honour already existing PORT setup
export PORT=${PORT:-80}

echo "=> Starting meteor app on port:$PORT"
node main.js
