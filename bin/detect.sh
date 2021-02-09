#!/bin/sh

# this pack is valid for apps with a hello.txt in the root
if [ -f $1/hoss-config.json ]; then
  echo "Detect dx portal repo"
  exit 0
else
  exit 1
fi
