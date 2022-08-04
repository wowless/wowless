#!/bin/bash
mkdir -p out
f() {
  for p in wow wowt wow_classic wow_classic_era wow_classic_era_ptr wow_classic_ptr wow_beta wow_classic_beta; do
    echo -n "$p: "
    if bin/run.sh -p "$p" -e1 &> out/"$p".txt; then
      echo success
    else
      echo failure
    fi
  done
}
time f
ls -l out
