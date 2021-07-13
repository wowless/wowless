#!/bin/bash
loglevel=${1-100}
eval $(.lua/bin/luarocks path)
.lua/bin/lua -e "require('wowless.runner').run($loglevel)"
