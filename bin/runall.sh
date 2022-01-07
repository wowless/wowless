#!/bin/bash
mkdir -p out
bin/run.sh 0 wow Mainline &> out/wow.txt &
bin/run.sh 0 wowt Mainline &> out/wowt.txt &
bin/run.sh 0 wow_classic TBC &> out/wow_classic.txt &
bin/run.sh 0 wow_classic_ptr TBC &> out/wow_classic_ptr.txt &
bin/run.sh 0 wow_classic_era Vanilla &> out/wow_classic_era.txt &
bin/run.sh 0 wow_classic_era_ptr Vanilla &> out/wow_classic_era_ptr.txt &
wait
