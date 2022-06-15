#!/bin/bash
set -e
bin/build.sh
tainted-lua/build/linux/bin/Release/lua5.1 tools/gentest.lua
busted -- "$@"
