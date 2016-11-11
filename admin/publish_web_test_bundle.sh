#!/bin/sh
set -e
my_dir=`dirname $0`
. ${my_dir}/lib.sh
. ${my_dir}/tests/test_lib.sh

clean() {
  rm -rf "${base_app_name}" || true
}

meteor_version=$1

if [ -z "${meteor_version}" ]; then
  echo "Please pass Meteor version number as the first argument."
  exit 1
fi

base_app_name="spaceglue-test-app-${meteor_version}"

trap "echo Couldn't build test app for ${meteor_version} && exit 1" EXIT

cd /tmp
clean


create_meteor_test_app "${base_app_name}" "${meteor_version}"

echo "  => Building Meteor ${meteor_version}"
meteor build \
  --architecture=os.linux.x86_64 \
  "../${base_app_name}-bundle" \
  2>&1 > /dev/null

if ! [ -z "$AWS_PROFILE" ]; then
  echo "Publishing ${meteor_version} to AWS ${s3_bucket_name}..."
  AWS_REGION="${s3_bucket_region}" \
    aws s3 cp \
    /tmp/${base_app_name}-bundle/${base_app_name}.tar.gz \
    s3://${s3_bucket_name}/meteor-${meteor_version}.tar.gz \
    --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
  clean
else
  echo "Your bundle is now ready in /tmp/${base_app_name}.  \c"
  echo "Make sure to publish it to S3 appropriately."
  echo
  echo "In the future, if you have the aws s3 command installed \c"
  echo "(with 'pip install awscli'), you can set AWS_PROFILE and it will \c"
  echo "be published automatically."
fi

trap - EXIT

set +e
