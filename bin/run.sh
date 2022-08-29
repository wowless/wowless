#!/bin/bash
product="$1"
shift
ninja "$product"
tainted-lua/build/linux/bin/Release/lua5.1 wowless.lua -p "$product" "$@"
