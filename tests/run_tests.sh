#!/bin/sh

set -e
set -x

export NODE_VERSION=${NODE_VERSION:-4.6.1}

./build_it.sh

./test_meteor_app.sh
./test_meteor_app_with_devbuild.sh

./test_bundle_local_mount.sh

# These use BUNDLE_URL from S3
./test_bundle_web.sh
./test_binary_build_on_base.sh
./test_binary_build_on_bin_build.sh

./test_phantomjs.sh
./test_no_app.sh
