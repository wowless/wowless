#!/bin/bash
set -e
luacheck -q data spec tools wowapi wowless ./*.lua
(cd tainted-lua && cmake --preset linux && cmake --build --preset linux)
luarocks build --no-install
busted --lua=tainted-lua/build/linux/bin/Release/lua5.1 -- "$@"
