#!/bin/bash
loglevel=${1-0}
dir=extracts/${2-wow_classic}/Interface
version=${3-TBC}
eval $(.lua/bin/luarocks path)
.lua/bin/lua -e "require('wowless.runner').run($loglevel, '$dir', '$version')"
