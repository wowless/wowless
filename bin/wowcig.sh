#!/bin/bash
set -e
eval "$(.lua/bin/luarocks path)"
.lua/bin/luarocks install wowcig
for p in wow wowt wow_classic wow_classic_era wow_classic_era_ptr wow_classic_ptr; do
  d="extracts/$p"
  if [ "$1" != "skipcig" ]; then
    rm -f "$d"
    .lua/bin/lua tools/dblist.lua | sed 's/^/-d /' | xargs .lua/bin/wowcig -v -p "$p"
  fi
  v=$(basename "$(readlink "$d")")
  if ! bash -c "curl -s http://storage.googleapis.com/wow.ferronn.dev/gscrapes/$v.lua | \
       .lua/bin/lua tools/gextract.lua /dev/stdin 2>/dev/null > \
       $d/Interface/GlobalEnvironment.lua"
  then
    echo "failed to extract globals for $p"
  fi
done
