#!/bin/sh

set -e

if [ -d "$HOME/.meteor" ]; then
  echo "Meteor Home directory already exists!"
else
  echo "Meteor Home directory does not exist."
fi

export
curl -sL https://install.meteor.com | sed s/--progress-bar/-sL/g | /bin/sh
