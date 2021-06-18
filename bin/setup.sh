#!/bin/bash
set -e
DIR=$(dirname $0)/../.lua
pip3 install hererocks
hererocks -l 5.1 -r 3.5.0 $DIR
eval $($DIR/bin/luarocks path)
luarocks install luacheck
