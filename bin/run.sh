#!/bin/bash
set -e
product="$1"
shift
cmake --build --preset default --target wowless "${product}"
build/cmake/wowless run -p "$product" "$@"
