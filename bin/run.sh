#!/bin/bash
set -e
product="$1"
shift
ninja runtime "$product"
build/cmake/wowless wowless.lua -p "$product" "$@"
