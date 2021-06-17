#!/bin/bash
set -e
eval $(.lua/bin/luarocks path)
luacheck .
luarocks build --no-install
luarocks test
