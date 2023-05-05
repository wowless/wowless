#!/bin/bash
set -e
product="$1"
shift
ninja runtime "$product"
build/cmake/elune-prefix/src/elune/build/linux/install/bin/lua5.1 wowless.lua -p "$product" "$@"
