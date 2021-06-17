#!/bin/bash
set -e
pip3 install hererocks
hererocks -l 5.1 -r 3.5.0 .lua
eval $(.lua/bin/luarocks path)
luarocks install luacheck
