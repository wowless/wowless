#!/bin/bash
eval $(.lua/bin/luarocks path)
.lua/bin/lua tools/docs.lua extracts data/api
