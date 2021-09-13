#!/bin/bash
set -e
eval $(.lua/bin/luarocks path)
.lua/bin/luacheck -q addon spec wowapi wowless *.lua
.lua/bin/luarocks build --no-install
.lua/bin/luarocks test -- "$@"
