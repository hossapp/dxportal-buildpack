#!/usr/bin/env bash
# bin/compile <build-dir> <cache-dir>

# fail fast
set -e

# debug
# set -x

# parse and derive params
BUILD_DIR=$1
CACHE_DIR=$2
ENV_DIR=$3

EXIT_STATUS=0


function error() {
  echo " !     $*" >&2
  exit 1
}

function topic() {
  echo "-----> $*"
}

function indent() {
  c='s/^/       /'
  case $(uname) in
    Darwin) sed -l "$c";;
    *)      sed -u "$c";;
  esac
}

DXPORTAL_VERSION=`cat $ENV_DIR/DXPORTAL_VERSION`
GITHUB_AUTH_TOKEN=`cat $ENV_DIR/GITHUB_AUTH_TOKEN`
topic "Cloning dxportal $DXPORTAL_VERSION tag"
git clone  --depth 1 --branch ${DXPORTAL_VERSION} https://${GITHUB_AUTH_TOKEN}:x-oauth-basic@github.com/hossapp/dxportal.git /tmp/dxportal | indent

topic "Copy customer files"
rsync -a $BUILD_DIR/* /tmp/dxportal --exclude package.json --exclude package-lock.json | indent

# add customer dependencies to dxportal package.json
topic "Merge dependencies"
jq --argjson deps "$(jq ".dependencies" $BUILD_DIR/package.json)" '.dependencies += $deps' /tmp/dxportal/package.json > /tmp/dxportal/package.json_tmp && mv /tmp/dxportal/package.json_tmp /tmp/dxportal/package.json
shopt -s extglob

topic "Moving dxportal files to top level"
rsync -a /tmp/dxportal/* $BUILD_DIR | indent
