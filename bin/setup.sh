#!/bin/bash
set -e
python3 -m pip install -t .lua hererocks
PYTHONPATH=.lua .lua/bin/hererocks -l 5.1.4 -r 3.5.0 .lua
cd tainted-lua
cmake --preset linux
cmake --build --preset linux
cmake --install build/linux --prefix ../.lua
cd ..
# Overwrite previously installed lua with tainted-lua here.
mv -f .lua/bin/lua5.1 .lua/bin/lua
eval "$(.lua/bin/luarocks path)"
.lua/bin/luarocks install luacheck
.lua/bin/luarocks build --only-deps
