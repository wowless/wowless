#!/bin/bash
set -e
python3 -m pip install -t .lua hererocks
PYTHONPATH=.lua .lua/bin/hererocks -l 5.1 -r 3.5.0 .lua
eval $(.lua/bin/luarocks path)
.lua/bin/luarocks install luacheck
.lua/bin/luarocks build --only-deps
rm extracts/wow*
.lua/bin/wowcig -p wow
.lua/bin/wowcig -p wowt
.lua/bin/wowcig -p wow_classic
.lua/bin/wowcig -p wow_classic_era
.lua/bin/wowcig -p wow_classic_ptr
# TODO generalize
for v in 1.13.7.39692 2.5.2.39926 2.5.2.40011 9.1.0.39804
do
  curl -s http://storage.googleapis.com/wow.ferronn.dev/gscrapes/$v.lua | \
  .lua/bin/lua gextract.lua /dev/stdin > \
  extracts/$v/Interface/GlobalEnvironment.lua
done
