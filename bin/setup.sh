#!/bin/bash
set -e
python3 -m pip install -t .lua hererocks
PYTHONPATH=.lua .lua/bin/hererocks -l 5.1 -r 3.5.0 .lua
DIR="$PWD/.lua"
(cd tainted-lua && make linux && make install INSTALL_TOP="$DIR" && make clean)
eval $(.lua/bin/luarocks path)
.lua/bin/luarocks install luacheck
