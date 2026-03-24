#!/bin/bash
set -e
product="$1"
shift
cmake --build --preset default --target "wowless_${product}" "${product}"
"build/Release/wowless_${product}" run -p "$product" "$@"
