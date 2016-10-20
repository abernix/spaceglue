#!/bin/sh

set -x
set -e

: ${NODE_VERSION?"NODE_VERSION has not been set."}

my_dir=`dirname $0`
root_dir="$my_dir/.."

${root_dir}/build_it.sh

${my_dir}/test_meteor_app.sh

${my_dir}/test_bundle_local_mount.sh

# This uses BUNDLE_URL from S3
${my_dir}/test_bundle_web.sh

${my_dir}/test_phantomjs.sh
${my_dir}/test_no_app.sh
