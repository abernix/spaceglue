#!/usr/bin/env bash

: ${NODE_VERSION?"must be set."}

my_dir=`dirname $0`
root_dir="$my_dir/.."

if [ -z "${CIRCLE_NODE_TOTAL}" ] || [ -z "${CIRCLE_NODE_INDEX}" ]; then
  echo "Not running on CircleCI"
  exit 1
fi

our_scripts="\
${my_dir}/tests/test_meteor_app.sh
${my_dir}/tests/test_bundle_local_mount.sh
${my_dir}/tests/test_phantomjs.sh
${my_dir}/tests/test_no_app.sh
"

# Add meteor build versions
our_scripts="${our_scripts}$( \
  cat ${my_dir}/meteor_versions_to_test | \
  xargs -n1 -I% sh -c "\
    echo ${my_dir}/tests/test_meteor_app.sh % && \
    echo ${my_dir}/tests/test_bundle_web.sh %
  "\
)"

our_work="$( \
  echo "${our_scripts}" | \
  awk "NR % ${CIRCLE_NODE_TOTAL} == ${CIRCLE_NODE_INDEX}"
)"

if [ -z "${our_work}" ]; then
  echo "more parallelism than tests"
  exit 0
fi

on_test_error () {
  echo "ERROR: Some tests failed!"
  exit 1
}

# Bash-ism.
trap 'on_test_error' ERR

TEST_BUILD=true . ${my_dir}/build_it.sh

# Print a list of what we've done.
echo "============= Built Images ============="
echo "  base: ${DOCKER_IMAGE_NAME_BASE}"
echo "  builddeps: ${DOCKER_IMAGE_NAME_BUILDDEPS}"
echo "  onbuild: ${DOCKER_IMAGE_NAME_ONBUILD}"

# Export them so they're available to the build scripts.
export DOCKER_IMAGE_NAME_BASE
export DOCKER_IMAGE_NAME_BUILDDEPS
export DOCKER_IMAGE_NAME_ONBUILD
echo "${our_work}" | tr '\n' '\0' | xargs -n1 -0 -I% -t sh -c "% || exit 255"

trap - ERR
echo "All tests finished successfully."