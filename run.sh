#!/bin/bash
set -e
eval $(.lua/bin/luarocks path)
luacheck *.lua
luarocks build --no-install
luarocks test
