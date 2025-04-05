#!/bin/bash
set -e
product="$1"
shift
ninja build/cmake/wowless "$product"
build/cmake/wowless run -p "$product" "$@"
