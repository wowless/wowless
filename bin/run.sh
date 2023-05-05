#!/bin/bash
set -e
product="$1"
shift
ninja runtime "$product"
build/cmake/elune/bin/lua5.1 wowless.lua -p "$product" "$@"
