#!/bin/bash
set -e
python3 -m pip install -t .lua hererocks
PYTHONPATH=.lua .lua/bin/hererocks -l 5.1 -r 3.5.0 .lua
eval $(.lua/bin/luarocks path)
.lua/bin/luarocks install luacheck
.lua/bin/luarocks build --only-deps
if [ "$1" != "skipcig" ]
then
  rm -f extracts/wow*
  .lua/bin/wowcig -p wow
  .lua/bin/wowcig -p wowt
  .lua/bin/wowcig -p wow_classic
  .lua/bin/wowcig -p wow_classic_era
  .lua/bin/wowcig -p wow_classic_ptr
fi
for d in extracts/*
do
  if [ ! -h $d ]
  then
    v=$(basename $d)
    if ! bash -c "curl -s http://storage.googleapis.com/wow.ferronn.dev/gscrapes/$v.lua | \
         .lua/bin/lua gextract.lua /dev/stdin 2>/dev/null > \
         extracts/$v/Interface/GlobalEnvironment.lua"
    then
      echo "failed to extract globals for $v"
    fi
  fi
done
