#!/bin/bash
eval $(.lua/bin/luarocks path)
rm -rf extracts/addons
for id in 3358 13501 267285 334372 457175; do
  echo Retrieving curseforge $id
  .lua/bin/lua tools/curseforge.lua $id
done
function dotest() {
  local flavor=$1
  local build=$2
  local ptr=$3
  for d in extracts/addons/$flavor/*; do
    if [ -d $d ]; then
      echo Testing $flavor $(basename $d)
      bin/run.sh 0 $build $flavor $d 2>&1
      echo Testing $flavor $(basename $d) \(PTR\)
      bin/run.sh 0 $ptr $flavor $d 2>&1
    fi
  done
}
dotest Vanilla wow_classic_era wow_classic_era_ptr
dotest TBC wow_classic wow_classic_ptr
dotest Mainline wow wowt
