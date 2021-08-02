#!/bin/bash
set -e
python3 -m pip install -t .lua hererocks
PYTHONPATH=.lua .lua/bin/hererocks -l 5.1 -r 3.5.0 .lua
eval $(.lua/bin/luarocks path)
.lua/bin/luarocks install luacheck
.lua/bin/luarocks build --only-deps
.lua/bin/wowcig -p wow
.lua/bin/wowcig -p wowt
.lua/bin/wowcig -p wow_classic
.lua/bin/wowcig -p wow_classic_era
.lua/bin/wowcig -p wow_classic_ptr
