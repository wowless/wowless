#!/bin/bash
mkdir -p out
f() {
  for p in wow wowt wow_classic wow_classic_era wow_classic_era_ptr wow_classic_ptr; do
    bin/run.sh -p $p &> out/$p.txt &
  done
  wait
}
time f
ls -l out
