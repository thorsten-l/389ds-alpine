#!/bin/bash

OS_VERSION=3.14
DS_VERSION=1.4.4.17
echo "OS_VERSION=$OS_VERSION"
echo "DS_VERSION=$DS_VERSION"

docker build --no-cache \
  --build-arg OS_VERSION="$OS_VERSION" \
  --build-arg DS_VERSION="$DS_VERSION" \
  -t "389ds:base-alpine" .
