#!/bin/bash
eval $(.lua/bin/luarocks path)
.lua/bin/lua wowless.lua "$@"
