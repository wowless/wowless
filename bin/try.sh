#!/bin/bash
loglevel=${1-100}
version=${2-wow_classic}
eval $(.lua/bin/luarocks path)
.lua/bin/lua -e "require('wowless.runner').run($loglevel, '$version')"
