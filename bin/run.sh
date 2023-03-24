#!/bin/bash
set -e
product="$1"
shift
ninja build/elune/lua/lua5.1 runtime "$product"
build/elune/lua/lua5.1 wowless.lua -p "$product" "$@"
