#!/bin/bash
set -e
bin/build.sh
lua tools/gentest.lua
busted --lua=tainted-lua/build/linux/bin/Release/lua5.1 -- "$@"
