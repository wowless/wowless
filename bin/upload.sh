#!/bin/bash
set -e
DIR=$(dirname $0)/../.lua
eval $($DIR/bin/luarocks path)
luarocks upload *.rockspec --force --api-key="$1"
