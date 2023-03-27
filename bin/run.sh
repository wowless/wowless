#!/bin/bash
set -e
product="$1"
shift
ninja build/cmake/vendor/elune/lua/lua5.1 runtime "$product"
build/cmake/vendor/elune/lua/lua5.1 wowless.lua -p "$product" "$@"
