#!/bin/bash
set -e
for p in wow wowt wow_beta wow_classic wow_classic_beta wow_classic_era wow_classic_era_ptr wow_classic_ptr; do
  rm -f "extracts/$p"
  lua tools/dblist.lua "$p" | sed 's/^/-d /' | xargs wowcig -v -p "$p"
done
