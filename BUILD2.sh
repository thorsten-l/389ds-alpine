#!/bin/bash

./private/LOGIN.sh

PLATFORM=$1
OS_VERSION=$2
DS_VERSION=$3
echo "OS_VERSION=$OS_VERSION"
echo "DS_VERSION=$DS_VERSION"
shift
shift
shift

TAGS=""

while (( $# )); do
  TAGS="$TAGS --tag ghcr.io/thorsten-l/389ds-alpine-$PLATFORM:$1"
  shift
done

BUILDING_TAGS=$(echo $TAGS | tr ' ' "\n")

docker build \
  --build-arg OS_VERSION="$OS_VERSION" \
  --build-arg DS_VERSION="$DS_VERSION" \
  $BUILDING_TAGS .

docker push --all-tags "ghcr.io/thorsten-l/389ds-alpine-$PLATFORM"
