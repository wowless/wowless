#!/bin/bash
set -e
eval "$(.lua/bin/luarocks path)"
p="$1"
v="$(gsutil cat gs://wowless.dev/extracts/"$p".txt)"
mkdir -p extracts
gsutil cp gs://wowless.dev/extracts/"$v".zip extracts/
unzip extracts/"$v".zip -d extracts
gsutil cp gs://wowless.dev/gscrapes/"$v".lua extracts/
.lua/bin/lua tools/gextract.lua extracts/"$v".lua > extracts/"$v"/Interface/GlobalEnvironment.lua
ln -sf "$v" extracts/"$p"
