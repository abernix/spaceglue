#!/bin/sh

s3_bucket_name="abernix-meteord-tests"
s3_bucket_region="us-west-2"

cver () {
  echo $1 | perl -n \
  -e '@ver = /^(?:[^\@]+\@)?([0-9]+)\.([0-9]+)(?:\.([0-9]+))?(?:\.([0-9]+))?/;' \
  -e 'printf "%04s%04s%04s%04s", @ver;'
}
