#!/bin/bash
set -e
DIR="$PWD/.lua"
python3 -m pip install -t "$DIR" hererocks
"$DIR"/bin/hererocks -l 5.1 -r 3.5.0 "$DIR"
(cd tainted-lua && make linux && make install INSTALL_TOP="$DIR" && make clean)
eval $("$DIR"/bin/luarocks path)
luarocks install luacheck
