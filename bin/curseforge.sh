#!/bin/bash
set -e
eval "$(.lua/bin/luarocks path)"
.lua/bin/lua tools/curseforge.lua "$@"
