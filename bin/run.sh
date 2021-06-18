#!/bin/bash
set -e
DIR=$(dirname $0)/../.lua
eval $($DIR/bin/luarocks path)
luacheck .
luarocks build --no-install
luarocks test -- "$@"
