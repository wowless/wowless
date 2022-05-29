#!/bin/bash
set -e
luacheck -q data spec tools wowapi wowless ./*.lua
bin/build.sh
lua tools/gentest.lua
busted --lua=tainted-lua/build/linux/bin/Release/lua5.1 -- "$@"
