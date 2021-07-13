#!/bin/bash
set -e
eval $(.lua/bin/luarocks path)
.lua/bin/luarocks upload *.rockspec --force --api-key="$1"
