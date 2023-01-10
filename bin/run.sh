#!/bin/bash
set -e
product="$1"
shift
ninja vendor/elune/build/linux/bin/Release/lua5.1 wowless/ext.so "$product"
vendor/elune/build/linux/bin/Release/lua5.1 wowless.lua -p "$product" "$@"
