#!/bin/bash
set -e
product="$1"
shift
ninja runtime "$product"
bazel-bin/wowless wowless.lua -p "$product" "$@"
