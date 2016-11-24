#!/bin/sh

set -e
my_dir=`dirname $0`
path=`pwd`

if [ -d /bundle ]; then
  echo "=> Found /bundle"
  tar -xz -C $HOME --no-same-owner --file /bundle/*.tar.gz
  cd $HOME/bundle
elif [ -d $HOME/bundle ]; then
  echo "=> Found $HOME/bundle"
  cd $HOME/bundle
  tar -xz --no-same-owner --file $HOME/bundle/*.tar.gz
  cd bundle/
elif [ -n "$BUNDLE_URL" ]; then
  echo "=> BUNDLE_URL is set"
  cd $HOME/
  curl -L -o bundle.tar.gz $BUNDLE_URL
  tar -xz --no-same-owner --file bundle.tar.gz
  cd bundle/
elif [ -d $HOME/built_app ]; then
  echo "=> Found $HOME/built_app"
  cd $HOME/built_app
elif [ -d /built_app ]; then
  echo "=> Found /built_app"
  cd /built_app
else
  echo "=> You don't have an meteor app to run in this image."
  exit 1
fi

echo "=> Bundle Version"
bundle_meteor_release="$(node ${path}/${my_dir}/lib/get_bundle_meteor_release)"
echo " > ${bundle_meteor_release}"

set +e
echo "=> Proper Node Version"
node ${path}/${my_dir}/lib/check_node_for_meteor ${bundle_meteor_release}
case $? in
  30)
     echo "Unable to check valid version, newer?"
     ;;
  31)
     echo "Invalid version of Node"
     ;;
  0)
     echo "Correct Node Version"
     ;;
esac
set -e

echo "=> Actual Node Version"
ACTUAL_NODE_VERSION="$(node --version | sed 's/^v//')"
echo " > ${ACTUAL_NODE_VERSION}"

# Set a delay to wait to start meteor container
if [ -n "$DELAY" ]; then
  echo "Delaying startup for $DELAY seconds"
  sleep $DELAY
fi

echo "=> Executing NPM install within Bundle"
(cd programs/server && npm install --unsafe-perm)

echo "=> Starting meteor app"
node $NODE_OPTIONS main.js
