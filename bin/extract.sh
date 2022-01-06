#!/bin/bash
set -e
eval "$(.lua/bin/luarocks path)"
p="$1"
v="$(gsutil cat gs://wowless.dev/extracts/"$p".txt)"
echo -en "Extracting $v..."
mkdir -p extracts
gsutil -q cp gs://wowless.dev/extracts/"$v".zip extracts/
unzip -d extracts -q -u extracts/"$v".zip
gsutil -q cp gs://wowless.dev/gscrapes/"$v".lua extracts/
.lua/bin/lua tools/gextract.lua extracts/"$v".lua > extracts/"$v"/Interface/GlobalEnvironment.lua
ln -sf "$v" extracts/"$p"
echo " done."
